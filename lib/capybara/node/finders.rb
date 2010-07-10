module Capybara
  class Node
    module Finders
      #return node identified by locator or raise ElementNotFound(using desc)
      def locate(*args)
        node = wait_conditionally_until { find(*args) }
      ensure
        options = if args.last.is_a?(Hash) then args.last else {} end
        raise Capybara::ElementNotFound, options[:message] || "Unable to locate '#{args[1] || args[0]}'" unless node
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

        if text = options[:text]
          text = Regexp.escape(text) unless text.kind_of?(Regexp)

          results = results.select { |node| node.text.match(text) }
        end

        if options[:visible] or Capybara.ignore_hidden_elements
          results = results.select { |node| node.visible? }
        end

        results.map { |n| Capybara::Element.new(session, n) }
      end

    protected

      def normalize_locator(kind, locator=nil)
        kind, locator = Capybara.default_selector, kind if locator.nil?
        locator = XPath.from_css(locator) if kind == :css
        locator
      end

      def wait_conditionally_until
        if driver.wait? then session.wait_until { yield } else yield end
      end

    end
  end
end
