module Capybara
  # this is a class for generating XPath queries, use it like this:
  #     Xpath.text_field('foo').link('blah').to_s
  # this will generate an XPath that matches either a text field or a link
  class XPath

    class << self
      def from_css(css)
        Nokogiri::CSS.xpath_for(css).first
      end
      alias_method :for_css, :from_css

      def wrap(path)
        if path.is_a?(self)
          path
        else
          new(path.to_s)
        end
      end

      def respond_to?(method)
        new.respond_to?(method)
      end

      def method_missing(*args)
        new.send(*args)
      end
    end

    attr_reader :paths

    def initialize(*paths)
      @paths = paths
    end

    def field(locator)
      fillable_field(locator).input_field(:file, locator).checkbox(locator).radio_button(locator).select(locator)
    end

    def fillable_field(locator)
      [:text, :password, :email, :url, :search, :tel, :color].inject(text_area(locator)) do |all, type|
        all.input_field(type, locator)
      end
    end

    def content(locator)
      append("/descendant-or-self::*[contains(.,#{s(locator)})]")
    end

    def table(locator)
      append("//table[@id=#{s(locator)} or contains(caption,#{s(locator)})]")
    end

    def fieldset(locator)
      append("//fieldset[@id=#{s(locator)} or contains(legend,#{s(locator)})]")
    end

    def link(locator)
      xpath = append("//a[@id=#{s(locator)} or contains(.,#{s(locator)}) or contains(@title,#{s(locator)})]")
      xpath.prepend("//a[text()=#{s(locator)} or @title=#{s(locator)}]")
    end

    def button(locator)
      xpath = append("//input[@type='submit' or @type='image'][@id=#{s(locator)} or contains(@value,#{s(locator)})]")
      xpath = xpath.append("//button[@id=#{s(locator)} or contains(@value,#{s(locator)}) or contains(.,#{s(locator)})]")
      xpath = xpath.prepend("//input[@type='submit' or @type='image'][@value=#{s(locator)}]")
      xpath = xpath.prepend("//button[@value=#{s(locator)} or text()=#{s(locator)}]")
    end

    def text_area(locator)
      add_field(locator, "//textarea")
    end

    def select(locator)
      add_field(locator, "//select")
    end

    def input_field(type, locator)
      add_field(locator, "//input[@type='#{type}']")
    end

    def scope(scope)
      XPath.new(*paths.map { |p| scope + p })
    end

    def to_s
      @paths.join(' | ')
    end

    def append(path)
      XPath.new(*[@paths, XPath.wrap(path).paths].flatten)
    end

    def prepend(path)
      XPath.new(*[XPath.wrap(path).paths, @paths].flatten)
    end

    def checkbox(locator)
      input_field(:checkbox, locator)
    end

    def radio_button(locator)
      input_field(:radio, locator)
    end

    [:text, :password, :email, :url, :search, :tel, :color, :file].each do |type|
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{type}_field(locator)
          input_field(:#{type}, locator)
        end
      RUBY
    end

  protected

    def add_field(locator, field)
      xpath = append("#{field}[@id=#{s(locator)}]")
      xpath = xpath.append("#{field}[@name=#{s(locator)}]")
      xpath = xpath.append("#{field}[@id=//label[contains(.,#{s(locator)})]/@for]")
      xpath = xpath.append("//label[contains(.,#{s(locator)})]#{field}")
      xpath.prepend("#{field}[@id=//label[text()=#{s(locator)}]/@for]")
    end

    # Sanitize a String for putting it into an xpath query
    def s(string)
      if string.include?("'")
        string = string.split("'", -1).map do |substr|
          "'#{substr}'"
        end.join(%q{,"'",})
        "concat(#{string})"
      else
        "'#{string}'"
      end

    end

  end
end
