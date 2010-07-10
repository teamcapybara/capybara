module Capybara
  class Node
    module Matchers
      def has_xpath?(path, options={})
        wait_conditionally_until do
          results = all(:xpath, path, options)

          if options[:count]
            results.size == options[:count]
          else
            results.size > 0
          end
        end
      rescue Capybara::TimeoutError
        return false
      end

      def has_no_xpath?(path, options={})
        wait_conditionally_until do
          results = all(:xpath, path, options)

          if options[:count]
            results.size != options[:count]
          else
            results.empty?
          end
        end
      rescue Capybara::TimeoutError
        return false
      end

      def has_css?(path, options={})
        has_xpath?(XPath.from_css(path), options)
      end

      def has_no_css?(path, options={})
        has_no_xpath?(XPath.from_css(path), options)
      end

      def has_content?(content)
        has_xpath?(XPath.content(content))
      end

      def has_no_content?(content)
        has_no_xpath?(XPath.content(content))
      end

      def has_link?(locator)
        has_xpath?(XPath.link(locator))
      end

      def has_no_link?(locator)
        has_no_xpath?(XPath.link(locator))
      end

      def has_button?(locator)
        has_xpath?(XPath.button(locator))
      end

      def has_no_button?(locator)
        has_no_xpath?(XPath.button(locator))
      end

      def has_field?(locator, options={})
        has_xpath?(XPath.field(locator, options))
      end

      def has_no_field?(locator, options={})
        has_no_xpath?(XPath.field(locator, options))
      end

      def has_checked_field?(locator)
        has_xpath?(XPath.field(locator, :checked => true))
      end

      def has_unchecked_field?(locator)
        has_xpath?(XPath.field(locator, :unchecked => true))
      end

      def has_select?(locator, options={})
        has_xpath?(XPath.select(locator, options))
      end

      def has_no_select?(locator, options={})
        has_no_xpath?(XPath.select(locator, options))
      end

      def has_table?(locator, options={})
        has_xpath?(XPath.table(locator, options))
      end

      def has_no_table?(locator, options={})
        has_no_xpath?(XPath.table(locator, options))
      end
    end
  end
end
