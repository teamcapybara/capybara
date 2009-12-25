module Capybara
  module Searchable
    def has_content?(content)
      has_xpath?(XPath.content(content).to_s)
    end

    def has_xpath?(path, options={})
      results = all(path, options)
      
      if options[:count]
        results.size == options[:count]
      else
        results.size > 0
      end
    end

    def has_css?(path, options={})
      has_xpath?(XPath.from_css(path), options)
    end

    def find(locator, options = {})
      all(locator, options).first
    end
     
    def find_field(locator)
      find(XPath.field(locator))
    end
    alias_method :field_labeled, :find_field

    def find_link(locator)
      find(XPath.link(locator))
    end

    def find_button(locator)
      find(XPath.button(locator))
    end
    
    def find_by_id(id) 
      find(Xpath.for_css("##{id}"))
    end

    def all(locator, options = {})
      results = all_unfiltered(locator)
      
      if options[:text]
        results = results.select { |n| n.text.match(options[:text]) }
      end
      
      if options[:visible] == true
        results.reject! { |n| !n.visible? }
      end
      
      results
    end
    
    private
    
    def all_unfiltered(locator)
      raise "Must be overridden"
    end

  end
end