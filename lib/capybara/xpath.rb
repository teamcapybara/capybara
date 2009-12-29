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
      fillable_field(locator).file_field(locator).checkbox(locator).radio_button(locator).select(locator)
    end

    def fillable_field(locator)
      text_field(locator).password_field(locator).text_area(locator)
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
      append("//a[@id=#{s(locator)} or contains(.,#{s(locator)}) or @title=#{s(locator)}]")
    end
    
    def button(locator)
      xpath = append("//input[@type='submit' or @type='image'][@id=#{s(locator)} or contains(@value,#{s(locator)})]")
      xpath.append("//button[@id=#{s(locator)} or contains(@value,#{s(locator)}) or contains(.,#{s(locator)})]")
    end

    def text_field(locator)
      add_field(locator, "//input[@type='text']")
    end

    def password_field(locator)
      add_field(locator, "//input[@type='password']")
    end

    def text_area(locator)
      add_field(locator, "//textarea")
    end

    def radio_button(locator)
      add_field(locator, "//input[@type='radio']")
    end

    def checkbox(locator)
      add_field(locator, "//input[@type='checkbox']")
    end

    def select(locator)
      add_field(locator, "//select")
    end

    def file_field(locator)
      add_field(locator, "//input[@type='file']")
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

  protected
  
    def add_field(locator, field)
      xpath = append("#{field}[@id=#{s(locator)}]")
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
