module Capybara
  class Node
    module Actions

      ##
      #
      # Finds a button or link by id, text or value and clicks it. Also looks at image
      # alt text inside the link.
      #
      # @param [String] locator      Text, id or value of link or button
      #
      def click_link_or_button(locator)
        msg = "no link or button '#{locator}' found"
        find(:xpath, XPath.link(locator).button(locator), :message => msg).click
      end

      ##
      #
      # Finds a link by id or text and clicks it. Also looks at image
      # alt text inside the link.
      #
      # @param [String] locator      Text, id or text of link
      #
      def click_link(locator)
        msg = "no link with title, id or text '#{locator}' found"
        find(:xpath, XPath.link(locator), :message => msg).click
      end

      ##
      #
      # Finds a button by id, text or value and clicks it.
      #
      # @param [String] locator      Text, id or value of button
      #
      def click_button(locator)
        msg = "no button with value or id or text '#{locator}' found"
        find(:xpath, XPath.button(locator), :message => msg).click
      end

      ##
      #
      # Locate a text field or text area and fill it in with the given text
      # The field can be found via its name, id or label text.
      #
      #     page.fill_in 'Name', :with => 'Bob'
      #
      # @param [String] locator           Which field to fill in
      # @param [Hash{:with => String}]    The value to fill in
      #
      def fill_in(locator, options={})
        msg = "cannot fill in, no text field, text area or password field with id, name, or label '#{locator}' found"
        raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
        find(:xpath, XPath.fillable_field(locator), :message => msg).set(options[:with])
      end

      ##
      #
      # Find a radio button and mark it as checked. The radio button can be found
      # via name, id or label text.
      #
      #     page.choose('Male')
      #
      # @param [String] locator           Which radio button to choose
      #
      def choose(locator)
        msg = "cannot choose field, no radio button with id, name, or label '#{locator}' found"
        find(:xpath, XPath.radio_button(locator), :message => msg).set(true)
      end

      ##
      #
      # Find a check box and mark it as checked. The check box can be found
      # via name, id or label text.
      #
      #     page.check('German')
      #
      # @param [String] locator           Which check box to check
      #
      def check(locator)
        msg = "cannot check field, no checkbox with id, name, or label '#{locator}' found"
        find(:xpath, XPath.checkbox(locator), :message => msg).set(true)
      end

      ##
      #
      # Find a check box and mark uncheck it. The check box can be found
      # via name, id or label text.
      #
      #     page.uncheck('German')
      #
      # @param [String] locator           Which check box to uncheck
      #
      def uncheck(locator)
        msg = "cannot uncheck field, no checkbox with id, name, or label '#{locator}' found"
        find(:xpath, XPath.checkbox(locator), :message => msg).set(false)
      end

      ##
      #
      # Find a select box on the page and select a particular option from it. If the select
      # box is a multiple select, +select+ can be called multiple times to select more than
      # one option. The select box can be found via its name, id or label text.
      #
      #     page.uncheck('German')
      #
      # @param [String] locator           Which check box to uncheck
      #
      def select(value, options={})
        no_select_msg = "cannot select option, no select box with id, name, or label '#{options[:from]}' found"
        no_option_msg = "cannot select option, no option with text '#{value}' in select box '#{options[:from]}'"
        select = find(:xpath, XPath.select(options[:from]), :message => no_select_msg)
        select.find(:xpath, XPath.option(value), :message => no_option_msg).select_option
      end

      ##
      #
      # Find a select box on the page and select a particular option from it. If the select
      # box is a multiple select, +select+ can be called multiple times to select more than
      # one option. The select box can be found via its name, id or label text.
      #
      #     page.uncheck('German')
      #
      # @param [String] locator           Which check box to uncheck
      #
      def unselect(value, options={})
        no_select_msg = "cannot unselect option, no select box with id, name, or label '#{options[:from]}' found"
        no_option_msg = "cannot unselect option, no option with text '#{value}' in select box '#{options[:from]}'"
        select = find(:xpath, XPath.select(options[:from]), :message => no_select_msg)
        select.find(:xpath, XPath.option(value), :message => no_option_msg).unselect_option
      end

      ##
      #
      # Find a file field on the page and attach a file given its path. The file field can
      # be found via its name, id or label text.
      #
      #     page.attach_file(locator, '/path/to/file.png')
      #
      # @param [String] locator       Which field to attach the file to
      # @param [String] path          The path of the file that will be attached
      #
      def attach_file(locator, path)
        msg = "cannot attach file, no file field with id, name, or label '#{locator}' found"
        find(:xpath, XPath.file_field(locator), :message => msg).set(path)
      end

      ##
      #
      # Drag one element to another
      #
      # @deprecated    Use Capybara::Element#drag_to instead.
      #
      def drag(source_locator, target_locator)
        source = find(:xpath, source_locator, :message => "drag source '#{source_locator}' not found on page")
        target = find(:xpath, target_locator, :message => "drag target '#{target_locator}' not found on page")
        source.drag_to(target)
      end
    end
  end
end
