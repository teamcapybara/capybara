module Capybara
  module Node
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
        find(:xpath, XPath::HTML.link_or_button(locator), :message => msg).click
      end
      alias_method :click_on, :click_link_or_button

      ##
      #
      # Finds a link by id or text and clicks it. Also looks at image
      # alt text inside the link.
      #
      # @param [String] locator      Text, id or text of link
      #
      def click_link(locator)
        msg = "no link with title, id or text '#{locator}' found"
        find(:xpath, XPath::HTML.link(locator), :message => msg).click
      end

      ##
      #
      # Finds a button by id, text or value and clicks it.
      #
      # @param [String] locator      Text, id or value of button
      #
      def click_button(locator)
        msg = "no button with value or id or text '#{locator}' found"
        find(:xpath, XPath::HTML.button(locator), :message => msg).click
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
        find(:xpath, XPath::HTML.fillable_field(locator), :message => msg).set(options[:with])
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
        find(:xpath, XPath::HTML.radio_button(locator), :message => msg).set(true)
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
        find(:xpath, XPath::HTML.checkbox(locator), :message => msg).set(true)
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
        find(:xpath, XPath::HTML.checkbox(locator), :message => msg).set(false)
      end

      ##
      #
      # Find a select box on the page and select a particular option from it. If the select
      # box is a multiple select, +select+ can be called multiple times to select more than
      # one option. The select box can be found via its name, id or label text.
      #
      #     page.select 'March', :from => 'Month'
      #
      # @param [String] value             Which option to select
      # @param [Hash{:from => String}]    The id, name or label of the select box
      #
      def select(value, options={})
        if options.has_key?(:from)
          no_select_msg = "cannot select option, no select box with id, name, or label '#{options[:from]}' found"
          no_option_msg = "cannot select option, no option with text '#{value}' in select box '#{options[:from]}'"
          select = find(:xpath, XPath::HTML.select(options[:from]), :message => no_select_msg)
          select.find(:xpath, XPath::HTML.option(value), :message => no_option_msg).select_option
        else
          no_option_msg = "cannot select option, no option with text '#{value}'"
          find(:xpath, XPath::HTML.option(value), :message => no_option_msg).select_option
        end
      end

      ##
      #
      # Find a select box on the page and unselect a particular option from it. If the select
      # box is a multiple select, +unselect+ can be called multiple times to unselect more than
      # one option. The select box can be found via its name, id or label text.
      #
      #     page.unselect 'March', :from => 'Month'
      #
      # @param [String] value             Which option to unselect
      # @param [Hash{:from => String}]    The id, name or label of the select box
      #
      def unselect(value, options={})
        if options.has_key?(:from)
          no_select_msg = "cannot unselect option, no select box with id, name, or label '#{options[:from]}' found"
          no_option_msg = "cannot unselect option, no option with text '#{value}' in select box '#{options[:from]}'"
          select = find(:xpath, XPath::HTML.select(options[:from]), :message => no_select_msg)
          select.find(:xpath, XPath::HTML.option(value), :message => no_option_msg).unselect_option
        else
          no_option_msg = "cannot unselect option, no option with text '#{value}'"
          find(:xpath, XPath::HTML.option(value), :message => no_option_msg).unselect_option
        end
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
        raise Capybara::FileNotFound, "cannot attach file, #{path} does not exist" unless File.exist?(path.to_s)
        msg = "cannot attach file, no file field with id, name, or label '#{locator}' found"
        find(:xpath, XPath::HTML.file_field(locator), :message => msg).set(path)
      end
    end
  end
end
