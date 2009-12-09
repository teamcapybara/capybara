module Capybara
  # this is a class for generating XPath queries, use it like this:
  #     Xpath.text_field('foo').link('blah').to_s
  # this will generate an XPath that matches either a text field or a link
  class XPath
    class << self
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
      append("//*[contains(.,#{s(locator)})]")
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
      xpath = append("//input[@type='submit' or @type='image'][@id=#{s(locator)} or @value=#{s(locator)}]")
      xpath.append("//button[@id=#{s(locator)} or @value=#{s(locator)} or contains(.,#{s(locator)})]")
    end

    def text_field(locator)
      append("//input[@type='text'][@id=#{s(locator)} or @id=//label[contains(.,#{s(locator)})]/@for]")
    end

    def password_field(locator)
      append("//input[@type='password'][@id=#{s(locator)} or @id=//label[contains(.,#{s(locator)})]/@for]")
    end

    def text_area(locator)
      append("//textarea[@id=#{s(locator)} or @id=//label[contains(.,#{s(locator)})]/@for]")
    end

    def radio_button(locator)
      append("//input[@type='radio'][@id=#{s(locator)} or @id=//label[contains(.,#{s(locator)})]/@for]")
    end

    def checkbox(locator)
      append("//input[@type='checkbox'][@id=#{s(locator)} or @id=//label[contains(.,#{s(locator)})]/@for]")
    end

    def select(locator)
      append("//select[@id=#{s(locator)} or @id=//label[contains(.,#{s(locator)})]/@for]")
    end

    def file_field(locator)
      append("//input[@type='file'][@id=#{s(locator)} or @id=//label[contains(.,#{s(locator)})]/@for]")
    end

    def to_s
      @paths.join(' | ')
    end

  protected
  
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

    def append(path)
      XPath.new(*[@paths, path].flatten)
    end

  end
end
