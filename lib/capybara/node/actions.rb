# frozen_string_literal: true

module Capybara
  module Node
    module Actions
      ##
      #
      # Finds a button or link and clicks it.  See {Capybara::Node::Actions#click_button} and
      # {Capybara::Node::Actions#click_link} for what locator will match against for each type of element
      # @!macro waiting_behavior
      #   If the driver is capable of executing JavaScript, +$0+ will wait for a set amount of time
      #   and continuously retry finding the element until either the element is found or the time
      #   expires. The length of time +find+ will wait is controlled through {Capybara.default_max_wait_time}
      #
      #   @option options [false, Numeric] wait (Capybara.default_max_wait_time) Maximum time to wait for matching element to appear.
      #
      # @overload click_link_or_button([locator], options)
      #
      #   @param [String] locator      See {Capybara::Node::Actions#click_button} and {Capybara::Node::Actions#click_link}
      #
      # @return [Capybara::Node::Element]  The element clicked
      #
      def click_link_or_button(locator = nil, **options)
        find(:link_or_button, locator, options).click
      end
      alias_method :click_on, :click_link_or_button

      ##
      #
      # Finds a link by id, Capybara.test_id attribute, text or title and clicks it. Also looks at image
      # alt text inside the link.
      #
      # @macro waiting_behavior
      #
      # @overload click_link([locator], options)
      #   @param [String] locator         text, id, Capybara.test_id attribute, title or nested image's alt attribute
      #   @param options                  See {Capybara::Node::Finders#find_link}
      #
      # @return [Capybara::Node::Element]  The element clicked
      def click_link(locator = nil, **options)
        find(:link, locator, options).click
      end

      ##
      #
      # Finds a button on the page and clicks it.
      # This can be any \<input> element of type submit, reset, image, button or it can be a
      # \<button> element. All buttons can be found by their id, Capybara.test_id attribute, value, or title. \<button> elements can also be found
      # by their text content, and image \<input> elements by their alt attribute
      #
      # @macro waiting_behavior
      #
      # @overload click_button([locator], **options)
      #   @param [String] locator      Which button to find
      #   @param options     See {Capybara::Node::Finders#find_button}
      # @return [Capybara::Node::Element]  The element clicked
      def click_button(locator = nil, **options)
        find(:button, locator, options).click
      end

      ##
      #
      # Locate a text field or text area and fill it in with the given text
      # The field can be found via its name, id, Capybara.test_id attribute, or label text.
      # If no locator is provided will operate on self or a descendant
      #
      #     # will fill in a descendant fillable field with name, id, or label text matching 'Name'
      #     page.fill_in 'Name', with: 'Bob'
      #
      #     # will fill in `el` if it's a fillable field
      #     el.fill_in with: 'Tom'
      #
      #
      # @overload fill_in([locator], with:, **options)
      #   @param [String] locator                 Which field to fill in
      #   @param [Hash] options
      #   @param with: [String]                  The value to fill_in
      #   @macro waiting_behavior
      #   @option options [String] currently_with The current value property of the field to fill in
      #   @option options [Boolean] multiple      Match fields that can have multiple values?
      #   @option options [String] id             Match fields that match the id attribute
      #   @option options [String] name           Match fields that match the name attribute
      #   @option options [String] placeholder    Match fields that match the placeholder attribute
      #   @option options [String, Array<String>] class    Match fields that match the class(es) provided
      #   @option options [Hash] fill_options     Driver specific options regarding how to fill fields (Defaults come from Capybara.default_set_options)
      #
      # @return [Capybara::Node::Element]  The element filled_in
      def fill_in(locator = nil, with:, currently_with: nil, fill_options: {}, **find_options)
        find_options[:with] = currently_with if currently_with
        find_options[:allow_self] = true if locator.nil?
        find(:fillable_field, locator, find_options).set(with, fill_options)
      end

      # @!macro label_click
      #   @option options [Boolean] allow_label_click (Capybara.automatic_label_click) Attempt to click the label to toggle state if element is non-visible.

      ##
      #
      # Find a descendant radio button and mark it as checked. The radio button can be found
      # via name, id or label text. If no locator is provided this will match against self or
      # a descendant.
      #
      #     # will choose a descendant radio button with a name, id, or label text matching 'Male'
      #     page.choose('Male')
      #
      #     # will choose `el` if it's a radio button element
      #     el.choose()
      #
      # @overload choose([locator], **options)
      #   @param [String] locator           Which radio button to choose
      #
      #   @option options [String] option  Value of the radio_button to choose
      #   @option options [String] id             Match fields that match the id attribute
      #   @option options [String] name           Match fields that match the name attribute
      #   @option options [String, Array<String>] class    Match fields that match the class(es) provided
      #   @macro waiting_behavior
      #   @macro label_click
      #
      # @return [Capybara::Node::Element]  The element chosen or the label clicked
      def choose(locator = nil, **options)
        _check_with_label(:radio_button, true, locator, options)
      end

      ##
      #
      # Find a descendant check box and mark it as checked. The check box can be found
      # via name, id or label text. If no locator is provided this will match against
      # self or a descendant.
      #
      #     # will check a descendant checkbox with a name, id, or label text matching 'German'
      #     page.check('German')
      #
      #     # will check `el` if it's a checkbox element
      #     el.check()
      #
      #
      # @overload check([locator], **options)
      #   @param [String] locator           Which check box to check
      #
      #   @option options [String] option  Value of the checkbox to select
      #   @option options [String] id       Match fields that match the id attribute
      #   @option options [String] name     Match fields that match the name attribute
      #   @option options [String, Array<String>] class    Match fields that match the class(es) provided
      #   @macro label_click
      #   @macro waiting_behavior
      #
      # @return [Capybara::Node::Element]  The element checked or the label clicked
      def check(locator = nil, **options)
        _check_with_label(:checkbox, true, locator, options)
      end

      ##
      #
      # Find a descendant check box and uncheck it. The check box can be found
      # via name, id or label text. If no locator is provided this will match against
      # self or a descendant.
      #
      #     # will uncheck a descendant checkbox with a name, id, or label text matching 'German'
      #     page.uncheck('German')
      #
      #     # will uncheck `el` if it's a checkbox element
      #     el.uncheck()
      #
      #
      # @overload uncheck([locator], **options)
      #   @param [String] locator           Which check box to uncheck
      #
      #   @option options [String] option  Value of the checkbox to deselect
      #   @option options [String] id       Match fields that match the id attribute
      #   @option options [String] name     Match fields that match the name attribute
      #   @option options [String, Array<String>] class    Match fields that match the class(es) provided
      #   @macro label_click
      #   @macro waiting_behavior
      #
      # @return [Capybara::Node::Element]  The element unchecked or the label clicked
      def uncheck(locator = nil, **options)
        _check_with_label(:checkbox, false, locator, options)
      end

      ##
      #
      # If `:from` option is present, `select` finds a select box, or text input with associated datalist,
      # on the page and selects a particular option from it.
      # Otherwise it finds an option inside current scope and selects it.
      # If the select box is a multiple select, +select+ can be called multiple times to select more than
      # one option.
      # The select box can be found via its name, id or label text. The option can be found by its text.
      #
      #     page.select 'March', from: 'Month'
      #
      # @macro waiting_behavior
      #
      # @param value [String] Which option to select
      # @param from [String]  The id, Capybara.test_id atrtribute, name or label of the select box
      #
      # @return [Capybara::Node::Element]  The option element selected
      def select(value = nil, from: nil, **options)
        el = from ? find_select_or_datalist_input(from, options) : self

        if el.respond_to?(:tag_name) && (el.tag_name == 'input')
          select_datalist_option(el, value)
        else
          el.find(:option, value, options).select_option
        end
      end

      ##
      #
      # Find a select box on the page and unselect a particular option from it. If the select
      # box is a multiple select, +unselect+ can be called multiple times to unselect more than
      # one option. The select box can be found via its name, id or label text.
      #
      #     page.unselect 'March', from: 'Month'
      #
      # @macro waiting_behavior
      #
      # @param value [String]     Which option to unselect
      # @param from [String]      The id, Capybara.test_id attribute, name or label of the select box
      #
      # @return [Capybara::Node::Element]  The option element unselected
      def unselect(value = nil, from: nil, **options)
        scope = from ? find(:select, from, options) : self
        scope.find(:option, value, options).unselect_option
      end

      ##
      #
      # Find a descendant file field on the page and attach a file given its path. The file field can
      # be found via its name, id or label text. In the case of the file field being hidden for
      # styling reasons the `make_visible` option can be used to temporarily change the CSS of
      # the file field, attach the file, and then revert the CSS back to original. If no locator is
      # passed this will match self or a descendant.
      #
      #     # will attach file to a descendant file input element that has a name, id, or label_text matching 'My File'
      #     page.attach_file('My File', '/path/to/file.png')
      #
      #     # will attach file to el if it's a file input element
      #     el.attach_file('/path/to/file.png')
      #
      # @overload attach_file([locator], paths, **options)
      #   @macro waiting_behavior
      #
      #   @param [String] locator                  Which field to attach the file to
      #   @param [String, Array<String>] paths     The path(s) of the file(s) that will be attached
      #
      #   @option options [Symbol] match (Capybara.match)     The matching strategy to use (:one, :first, :prefer_exact, :smart).
      #   @option options [Boolean] exact (Capybara.exact)    Match the exact label name/contents or accept a partial match.
      #   @option options [Boolean] multiple Match field which allows multiple file selection
      #   @option options [String] id             Match fields that match the id attribute
      #   @option options [String] name           Match fields that match the name attribute
      #   @option options [String, Array<String>] class    Match fields that match the class(es) provided
      #   @option options [true, Hash] make_visible   A Hash of CSS styles to change before attempting to attach the file, if `true` { opacity: 1, display: 'block', visibility: 'visible' } is used (may not be supported by all drivers)
      #
      #   @return [Capybara::Node::Element]  The file field element
      def attach_file(locator = nil, paths, make_visible: nil, **options) # rubocop:disable Style/OptionalArguments
        Array(paths).each do |path|
          raise Capybara::FileNotFound, "cannot attach file, #{path} does not exist" unless File.exist?(path.to_s)
        end
        options[:allow_self] = true if locator.nil?
        # Allow user to update the CSS style of the file input since they are so often hidden on a page
        if make_visible
          ff = find(:file_field, locator, options.merge(visible: :all))
          while_visible(ff, make_visible) { |el| el.set(paths) }
        else
          find(:file_field, locator, options).set(paths)
        end
      end

    private

      def find_select_or_datalist_input(from, options)
        synchronize(Capybara::Queries::BaseQuery.wait(options, session_options.default_max_wait_time)) do
          begin
            find(:select, from, options)
          rescue Capybara::ElementNotFound => select_error
            raise if %i[selected with_selected multiple].any? { |option| options.key?(option) }

            begin
              find(:datalist_input, from, options)
            rescue Capybara::ElementNotFound => dlinput_error
              raise Capybara::ElementNotFound, "#{select_error.message} and #{dlinput_error.message}"
            end
          end
        end
      end

      def select_datalist_option(input, value)
        datalist_options = input.evaluate_script(DATALIST_OPTIONS_SCRIPT)
        option = datalist_options.find { |opt| opt.values_at('value', 'label').include?(value) }
        raise ::Capybara::ElementNotFound, %(Unable to find datalist option "#{value}") unless option

        input.set(option['value'])
      rescue ::Capybara::NotSupportedByDriverError
        # Implement for drivers that don't support JS
        datalist = find(:xpath, XPath.descendant(:datalist)[XPath.attr(:id) == input[:list]], visible: false)
        option = datalist.find(:datalist_option, value, disabled: false)
        input.set(option.value)
      end

      def while_visible(element, visible_css)
        visible_css = { opacity: 1, display: 'block', visibility: 'visible' } if visible_css == true
        _update_style(element, visible_css)
        raise ExpectationNotMet, 'The style changes in :make_visible did not make the file input visible' unless element.visible?

        begin
          yield element
        ensure
          _reset_style(element)
        end
      end

      def _update_style(element, style)
        element.execute_script(UPDATE_STYLE_SCRIPT, style)
      rescue Capybara::NotSupportedByDriverError
        warn 'The :make_visible option is not supported by the current driver - ignoring'
      end

      def _reset_style(element)
        element.execute_script(RESET_STYLE_SCRIPT)
      rescue StandardError # rubocop:disable Lint/HandleExceptions swallow extra errors
      end

      def _check_with_label(selector, checked, locator, allow_label_click: session_options.automatic_label_click, **options)
        options[:allow_self] = true if locator.nil?

        synchronize(Capybara::Queries::BaseQuery.wait(options, session_options.default_max_wait_time)) do
          begin
            el = find(selector, locator, options)
            el.set(checked)
          rescue StandardError => err
            raise unless allow_label_click && catch_error?(err)

            begin
              el ||= find(selector, locator, options.merge(visible: :all))
              el.session.find(:label, for: el, visible: true).click unless el.checked? == checked
            rescue StandardError # swallow extra errors - raise original
              raise err
            end
          end
        end
      end

      UPDATE_STYLE_SCRIPT = <<~'JS'
        this.capybara_style_cache = this.style.cssText;
        var css = arguments[0];
        for (var prop in css){
          if (css.hasOwnProperty(prop)) {
            this.style.setProperty(prop, css[prop], "important");
          }
        }
      JS

      RESET_STYLE_SCRIPT = <<~'JS'
        if (this.hasOwnProperty('capybara_style_cache')) {
          this.style.cssText = this.capybara_style_cache;
          delete this.capybara_style_cache;
        }
      JS

      DATALIST_OPTIONS_SCRIPT = <<~'JS'
        Array.prototype.slice.call((this.list||{}).options || []).
          filter(function(el){ return !el.disabled }).
          map(function(el){ return { "value": el.value, "label": el.label} })
      JS
    end
  end
end
