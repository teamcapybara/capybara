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
      def click_link_or_button(locator, options={})
        find(:link_or_button, locator, options).click
      end
      alias_method :click_on, :click_link_or_button

      ##
      #
      # Finds a link by id or text and clicks it. Also looks at image
      # alt text inside the link.
      #
      # @param [String] locator      Text, id or text of link
      # @param options
      # @option options [String] :href    The value the href attribute must be
      #
      def click_link(locator, options={})
        find(:link, locator, options).click
      end

      ##
      #
      # Finds a button by id, text or value and clicks it.
      #
      # @param [String] locator      Text, id or value of button
      #
      def click_button(locator, options={})
        find(:button, locator, options).click
      end

      ##
      #
      # Locate a text field or text area and fill it in with the given text
      # The field can be found via its name, id or label text.
      #
      #     page.fill_in 'Name', :with => 'Bob'
      #
      # @param [String] locator                 Which field to fill in
      # @param [Hash{:with => String}] options  The value to fill in
      #
      def fill_in(locator, options={})
        raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
        with = options.delete(:with)
        find(:fillable_field, locator, options).set(with)
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
      def choose(locator, options={})
        find(:radio_button, locator, options).set(true)
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
      def check(locator, options={})
        find(:checkbox, locator, options).set(true)
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
      def uncheck(locator, options={})
        find(:checkbox, locator, options).set(false)
      end

      ##
      #
      # Find a select box on the page and select a particular option from it. If the select
      # box is a multiple select, +select+ can be called multiple times to select more than
      # one option. The select box can be found via its name, id or label text.
      #
      #     page.select 'March', :from => 'Month'
      #
      # @param [String] value                   Which option to select
      # @param [Hash{:from => String}] options  The id, name or label of the select box
      #
      def select(value, options={})
        if options.has_key?(:from)
          from = options.delete(:from)
          find(:select, from, options).find(:option, value, options).select_option
        else
          find(:option, value, options).select_option
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
      # @param [String] value                   Which option to unselect
      # @param [Hash{:from => String}] options  The id, name or label of the select box
      #
      def unselect(value, options={})
        if options.has_key?(:from)
          from = options.delete(:from)
          find(:select, from, options).find(:option, value, options).unselect_option
        else
          find(:option, value, options).unselect_option
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
      # @param [String] path          The path of the file that will be attached, or an array of paths
      #
      def attach_file(locator, path, options={})
        Array(path).each do |p|
          raise Capybara::FileNotFound, "cannot attach file, #{p} does not exist" unless File.exist?(p.to_s)
        end
        find(:file_field, locator, options).set(path)
      end
    end
  end
end
