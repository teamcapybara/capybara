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

    def text_field(locator)
      append("//input[@type='text'][@id='#{locator}' or @id=//label[contains(.,'#{locator}')]/@for]")
    end

    def password_field(locator)
      append("//input[@type='password'][@id='#{locator}' or @id=//label[contains(.,'#{locator}')]/@for]")
    end

    def text_area(locator)
      append("//textarea[@id='#{locator}' or @id=//label[contains(.,'#{locator}')]/@for]")
    end

    def radio_button(locator)
      append("//input[@type='radio'][@id='#{locator}' or @id=//label[contains(.,'#{locator}')]/@for]")
    end

    def checkbox(locator)
      append("//input[@type='checkbox'][@id='#{locator}' or @id=//label[contains(.,'#{locator}')]/@for]")
    end

    def select(locator)
      append("//select[@id='#{locator}' or @id=//label[contains(.,'#{locator}')]/@for]")
    end

    def file_field(locator)
      append("//input[@type='file'][@id='#{locator}' or @id=//label[contains(.,'#{locator}')]/@for]")
    end

    def to_s
      @paths.join(' | ')
    end

  private

    def append(path)
      XPath.new(*[@paths, path].flatten)
    end

  end
end
