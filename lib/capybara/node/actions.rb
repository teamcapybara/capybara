module Capybara
  class Node
    module Actions
      def click_link_or_button(locator)
        msg = "no link or button '#{locator}' found"
        locate(:xpath, XPath.link(locator).button(locator), msg).click
      end

      def click_link(locator)
        msg = "no link with title, id or text '#{locator}' found"
        locate(:xpath, XPath.link(locator), msg).click
      end

      def click_button(locator)
        msg = "no button with value or id or text '#{locator}' found"
        locate(:xpath, XPath.button(locator), msg).click
      end

      def fill_in(locator, options={})
        msg = "cannot fill in, no text field, text area or password field with id, name, or label '#{locator}' found"
        raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
        locate(:xpath, XPath.fillable_field(locator), msg).set(options[:with])
      end

      def choose(locator)
        msg = "cannot choose field, no radio button with id, name, or label '#{locator}' found"
        locate(:xpath, XPath.radio_button(locator), msg).set(true)
      end

      def check(locator)
        msg = "cannot check field, no checkbox with id, name, or label '#{locator}' found"
        locate(:xpath, XPath.checkbox(locator), msg).set(true)
      end

      def uncheck(locator)
        msg = "cannot uncheck field, no checkbox with id, name, or label '#{locator}' found"
        locate(:xpath, XPath.checkbox(locator), msg).set(false)
      end

      def select(value, options={})
        msg = "cannot select option, no select box with id, name, or label '#{options[:from]}' found"
        locate(:xpath, XPath.select(options[:from]), msg).select_option(value)
      end

      def unselect(value, options={})
        msg = "cannot unselect option, no select box with id, name, or label '#{options[:from]}' found"
        locate(:xpath, XPath.select(options[:from]), msg).unselect_option(value)
      end

      def attach_file(locator, path)
        msg = "cannot attach file, no file field with id, name, or label '#{locator}' found"
        locate(:xpath, XPath.file_field(locator), msg).set(path)
      end

      def drag(source_locator, target_locator)
        source = locate(:xpath, source_locator, "drag source '#{source_locator}' not found on page")
        target = locate(:xpath, target_locator, "drag target '#{target_locator}' not found on page")
        source.drag_to(target)
      end
    end
  end
end
