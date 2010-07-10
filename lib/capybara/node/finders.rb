module Capybara
  class Node
    module Finders
      #return node identified by locator or raise ElementNotFound(using desc)
      def locate(kind_or_locator, locator=nil, fail_msg = nil)
        node = wait_conditionally_until { find(kind_or_locator, locator) }
      ensure
        raise Capybara::ElementNotFound, fail_msg || "Unable to locate '#{locator || kind_or_locator}'" unless node
        return node
      end

      def find(*args)
        all(*args).first
      end

      def find_field(locator)
        find(:xpath, XPath.field(locator))
      end
      alias_method :field_labeled, :find_field

      def find_link(locator)
        find(:xpath, XPath.link(locator))
      end

      def find_button(locator)
        find(:xpath, XPath.button(locator))
      end

      def find_by_id(id)
        find(:css, "##{id}")
      end

      def all(*args)
        options = if args.last.is_a?(Hash) then args.pop else {} end

        results = XPath.wrap(normalize_locator(*args)).paths.map do |path|
          base.find(path)
        end.flatten

        if options[:text]

          if options[:text].kind_of?(Regexp)
            regexp = options[:text]
          else
            regexp = Regexp.escape(options[:text]) 
          end

          results = results.select { |n| n.text.match(regexp) }
        end

        if options[:visible] or Capybara.ignore_hidden_elements
          results = results.select { |n| n.visible? }
        end

        results.map { |n| Capybara::Element.new(self, n) }
      end

    protected

      def normalize_locator(kind, locator=nil)
        kind, locator = Capybara.default_selector, kind if locator.nil?
        locator = XPath.from_css(locator) if kind == :css
        locator
      end

      def wait_conditionally_until
        if driver.wait? then wait_until { yield } else yield end
      end

    end
  end
end
