require 'xpath'

::XPath::Collection.class_eval do
  alias_method :paths, :expressions
end

module Capybara

  ##
  #
  # This is a class for generating XPath queries, use it like this:
  #
  #     Xpath.text_field('foo').link('blah').to_s
  #
  # This will generate an XPath that matches either a text field or a link.
  #
  module XPath

    include ::XPath
    extend self

    def from_css(css)
      collection(*Nokogiri::CSS.xpath_for(css).map { |selector| ::XPath::Expression::Literal.new(:".#{selector}") }.flatten)
    end
    alias_method :for_css, :from_css

    def link(locator)
      link = descendant(:a)[attr(:href)]
      link[attr(:id).equals(locator) | text.is(locator) | attr(:title).is(locator) | descendant(:img)[attr(:alt).is(locator)]]
    end

    def content(locator)
      child(:"descendant-or-self::*")[current.n.contains(locator)]
    end

    def button(locator)
      collection(
        descendant(:input)[attr(:type).one_of('submit', 'image', 'button')][attr(:id).equals(locator) | attr(:value).is(locator)],
        descendant(:button)[attr(:id).equals(locator) | attr(:value).is(locator) | text.is(locator)],
        descendant(:input)[attr(:type).equals('image')][attr(:alt).is(locator)]
      )
    end

    def link_or_button(locator)
      collection(link(locator), button(locator))
    end

    def fieldset(locator)
      descendant(:fieldset)[attr(:id).equals(locator) | descendant(:legend)[text.is(locator)]]
    end

    def field(locator, options={})
      if options[:with]
        fillable_field(locator, options)
      else
        xpath = descendant(:input, :textarea, :select)[attr(:type).one_of('submit', 'image', 'hidden').inverse]
        xpath = locate_field(xpath, locator)
        xpath = xpath[attr(:checked)] if options[:checked]
        xpath = xpath[attr(:checked).inverse] if options[:unchecked]
        xpath
      end
    end

    def fillable_field(locator, options={})
      xpath = descendant(:input, :textarea)[attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file').inverse]
      xpath = locate_field(xpath, locator)
      xpath = xpath[field_value(options[:with])] if options.has_key?(:with)
      xpath
    end

    def select(locator, options={})
      xpath = locate_field(descendant(:select), locator)

      options[:options].each do |option|
        xpath = xpath[descendant(:option).text.equals(option)]
      end if options[:options]

      [options[:selected]].flatten.each do |option|
        xpath = xpath[descendant(:option)[attr(:selected)].text.equals(option)]
      end if options[:selected]

      xpath
    end

    def checkbox(locator, options={})
      xpath = locate_field(descendant(:input)[attr(:type).equals('checkbox')], locator)
    end

    def radio_button(locator, options={})
      locate_field(descendant(:input)[attr(:type).equals('radio')], locator)
    end

    def file_field(locator, options={})
      locate_field(descendant(:input)[attr(:type).equals('file')], locator)
    end

    def option(name)
      descendant(:option)[text.n.is(name)]
    end

    def table(locator, options={})
      xpath = descendant(:table)[attr(:id).equals(locator) | descendant(:caption).contains(locator)]
      xpath = xpath[table_rows(options[:rows])] if options[:rows]
      xpath
    end

    def table_rows(rows)
      row_conditions = descendant(:tr)[table_row(rows.first)] 
      rows.drop(1).each do |row|
        row_conditions = row_conditions.next_sibling(:tr)[table_row(row)]
      end
      row_conditions
    end

    def table_row(cells)
      cell_conditions = child(:td, :th)[text.equals(cells.first)] 
      cells.drop(1).each do |cell|
        cell_conditions = cell_conditions.next_sibling(:td, :th)[text.equals(cell)]
      end
      cell_conditions
    end

    def escape(string)
      if string.include?("'")
        string = string.split("'", -1).map do |substr|
          "'#{substr}'"
        end.join(%q{,"'",})
        "concat(#{string})"
      else
        "'#{string}'"
      end
    end
    
    def wrap(path)
      if path.respond_to?(:to_xpaths)
        path.to_xpaths
      else
        [path.to_s].flatten
      end
    end

  protected

    def collection(*args)
      ::XPath::Collection.new(*args)
    end

    def locate_field(xpath, locator)
      collection(
        xpath[attr(:id).equals(locator) | attr(:name).equals(locator) | attr(:id).equals(anywhere(:label)[text.is(locator)].attr(:for))],
        descendant(:label)[text.is(locator)].descendant(xpath)
      )
    end

    def field_value(value)
      (text.is(value) & name.equals('textarea')) | (attr(:value).equals(value) & name.equals('textarea').inverse)
    end
  end
end
