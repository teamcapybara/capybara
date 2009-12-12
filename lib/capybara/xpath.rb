module Capybara
  # this is a class for generating XPath queries, use it like this:
  #     Xpath.text_field('foo').link('blah').to_s
  # this will generate an XPath that matches either a text field or a link
  class XPath
    class << self
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
      add_field(locator) { |id| "//input[@type='text'][@id=#{id}]" }
    end

    def password_field(locator)
      add_field(locator) { |id| "//input[@type='password'][@id=#{id}]" }
    end

    def text_area(locator)
      add_field(locator) { |id| "//textarea[@id=#{id}]" }
    end

    def radio_button(locator)
      add_field(locator) { |id| "//input[@type='radio'][@id=#{id}]" }
    end

    def checkbox(locator)
      add_field(locator) { |id| "//input[@type='checkbox'][@id=#{id}]" }
    end

    def select(locator)
      add_field(locator) { |id| "//select[@id=#{id}]" }
    end

    def file_field(locator)
      add_field(locator) { |id| "//input[@type='file'][@id=#{id}]" }
    end
    
    def scope(scope)
      XPath.new(*paths.map { |p| scope + p })
    end

    def to_s
      @paths.join(' | ')
    end

  protected
  
    def add_field(locator)
      xpath = append(yield(s(locator)))
      xpath = xpath.append(yield("//label[contains(.,#{s(locator)})]/@for"))
      xpath.prepend(yield("//label[text()=#{s(locator)}]/@for"))
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
    
    def prepend(path)
      XPath.new(*[path, @paths].flatten)
    end

    def append(path)
      XPath.new(*[@paths, path].flatten)
    end

  end
end
