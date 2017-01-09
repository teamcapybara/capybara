# frozen_string_literal: true
module Capybara
  module Node
    module Actions

      ##
      #
      # Finds a button or link by id, text or value and clicks it. Also looks at image
      # alt text inside the link.
      # @!macro waiting_behavior
      #   If the driver is capable of executing JavaScript, +$0+ will wait for a set amount of time
      #   and continuously retry finding the element until either the element is found or the time
      #   expires. The length of time +find+ will wait is controlled through {Capybara.default_max_wait_time}
      #
      #   @option options [false, Numeric] wait (Capybara.default_max_wait_time) Maximum time to wait for matching element to appear.
      #
      # @overload click_link_or_button([locator], options)
      #
      #   @param [String] locator      Text, id or value of link or button
      #
      # @return [Capybara::Node::Element]  The element clicked
      #
      def click_link_or_button(locator=nil, options={})
        locator, options = nil, locator if locator.is_a? Hash
        find(:link_or_button, locator, options).click
      end
      alias_method :click_on, :click_link_or_button

      ##
      #
      # Finds a link by id, text or title and clicks it. Also looks at image
      # alt text inside the link.
      #
      # @macro waiting_behavior
      #
      # @overload click_link([locator], options)
      #   @param [String] locator         text, id, title or nested image's alt attribute
      #   @param options                  See {Capybara::Node::Finders#find_link}
      #
      # @return [Capybara::Node::Element]  The element clicked
      def click_link(locator=nil, options={})
        locator, options = nil, locator if locator.is_a? Hash
        find(:link, locator, options).click
      end

      ##
      #
      # Finds a button on the page and clicks it.
      # This can be any \<input> element of type submit, reset, image, button or it can be a
      # \<button> element. All buttons can be found by their id, value, or title. \<button> elements can also be found
      # by their text content, and image \<input> elements by their alt attribute
      #
      # @macro waiting_behavior
      #
      # @overload click_button([locator], options)
      #   @param [String] locator      Which button to find
      #   @param options     See {Capybara::Node::Finders#find_button}
      # @return [Capybara::Node::Element]  The element clicked
      def click_button(locator=nil, options={})
        locator, options = nil, locator if locator.is_a? Hash
        find(:button, locator, options).click
      end

      ##
      #
      # Locate a text field or text area and fill it in with the given text
      # The field can be found via its name, id or label text.
      #
      #     page.fill_in 'Name', with: 'Bob'
      #
      #
      # @overload fill_in([locator], options={})
      #   @param [String] locator                 Which field to fill in
      #   @param [Hash] options
      #   @macro waiting_behavior
      #   @option options [String] :with          The value to fill in - required
      #   @option options [Hash] :fill_options    Driver specific options regarding how to fill fields
      #   @option options [String] :currently_with The current value property of the field to fill in
      #   @option options [Boolean] :multiple      Match fields that can have multiple values?
      #   @option options [String] :id             Match fields that match the id attribute
      #   @option options [String] :name           Match fields that match the name attribute
      #   @option options [String] :placeholder    Match fields that match the placeholder attribute
      #   @option options [String, Array<String>] :class    Match links that match the class(es) provided
      #
      # @return [Capybara::Node::Element]  The element filled_in
      def fill_in(locator, options={})
        locator, options = nil, locator if locator.is_a? Hash
        raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
        with = options.delete(:with)
        fill_options = options.delete(:fill_options)
        options[:with] = options.delete(:currently_with) if options.has_key?(:currently_with)
        find(:fillable_field, locator, options).set(with, fill_options)
      end

      # @!macro label_click
      #   @option options [Boolean] :allow_label_click (Capybara.automatic_label_click) Attempt to click the label to toggle state if element is non-visible.

      ##
      #
      # Find a radio button and mark it as checked. The radio button can be found
      # via name, id or label text.
      #
      #     page.choose('Male')
      #
      # @overload choose([locator], options)
      #   @param [String] locator           Which radio button to choose
      #
      #   @option options [String] :option  Value of the radio_button to choose
      #   @option options [String] :id             Match fields that match the id attribute
      #   @option options [String] :name           Match fields that match the name attribute
      #   @option options [String, Array<String>] :class    Match links that match the class(es) provided
      #   @macro waiting_behavior
      #   @macro label_click
      #
      # @return [Capybara::Node::Element]  The element chosen or the label clicked
      def choose(locator, options={})
        _check_with_label(:radio_button, true, locator, options)
      end

      ##
      #
      # Find a check box and mark it as checked. The check box can be found
      # via name, id or label text.
      #
      #     page.check('German')
      #
      #
      # @overload check([locator], options)
      #   @param [String] locator           Which check box to check
      #
      #   @option options [String] :option  Value of the checkbox to select
      #   @option options [String] id       Match fields that match the id attribute
      #   @option options [String] name     Match fields that match the name attribute
      #   @option options [String, Array<String>] :class    Match links that match the class(es) provided
      #   @macro label_click
      #   @macro waiting_behavior
      #
      # @return [Capybara::Node::Element]  The element checked or the label clicked
      def check(locator, options={})
        _check_with_label(:checkbox, true, locator, options)
      end

      ##
      #
      # Find a check box and mark uncheck it. The check box can be found
      # via name, id or label text.
      #
      #     page.uncheck('German')
      #
      #
      # @overload uncheck([locator], options)
      #   @param [String] locator           Which check box to uncheck
      #
      #   @option options [String] :option  Value of the checkbox to deselect
      #   @option options [String] id       Match fields that match the id attribute
      #   @option options [String] name     Match fields that match the name attribute
      #   @option options [String, Array<String>] :class    Match links that match the class(es) provided
      #   @macro label_click
      #   @macro waiting_behavior
      #
      # @return [Capybara::Node::Element]  The element unchecked or the label clicked
      def uncheck(locator, options={})
        _check_with_label(:checkbox, false, locator, options)
      end

      ##
      #
      # If `:from` option is present, `select` finds a select box on the page
      # and selects a particular option from it.
      # Otherwise it finds an option inside current scope and selects it.
      # If the select box is a multiple select, +select+ can be called multiple times to select more than
      # one option.
      # The select box can be found via its name, id or label text. The option can be found by its text.
      #
      #     page.select 'March', from: 'Month'
      #
      # @macro waiting_behavior
      #
      # @param [String] value                   Which option to select
      # @option options [String] :from  The id, name or label of the select box
      #
      # @return [Capybara::Node::Element]  The option element selected
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
      #     page.unselect 'March', from: 'Month'
      #
      # @macro waiting_behavior
      #
      # @param [String] value                   Which option to unselect
      # @param [Hash{:from => String}] options  The id, name or label of the select box
      #
      # @return [Capybara::Node::Element]  The option element unselected
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
      # @macro waiting_behavior
      #
      # @param [String] locator       Which field to attach the file to
      # @param [String] path          The path of the file that will be attached, or an array of paths
      #
      # @option options [Symbol] match (Capybara.match)     The matching strategy to use (:one, :first, :prefer_exact, :smart).
      # @option options [Boolean] exact (Capybara.exact)    Match the exact label name/contents or accept a partial match.
      # @option options [Boolean] multiple Match field which allows multiple file selection
      # @option options [String] id             Match fields that match the id attribute
      # @option options [String] name           Match fields that match the name attribute
      # @option options [String, Array<String>] :class    Match links that match the class(es) provided
      # @option options [true, Hash] make_visible   A Hash of CSS styles to change before attempting to attach the file, if `true` { opacity: 1, display: 'block', visibility: 'visible' } is used (may not be supported by all drivers)
      #
      # @return [Capybara::Node::Element]  The file field element
      def attach_file(locator, path, options={})
        locator, path, options = nil, locator, path if path.is_a? Hash
        Array(path).each do |p|
          raise Capybara::FileNotFound, "cannot attach file, #{p} does not exist" unless File.exist?(p.to_s)
        end
        # Allow user to update the CSS style of the file input since they are so often hidden on a page
        if style = options.delete(:make_visible)
          style = { opacity: 1, display: 'block', visibility: 'visible' } if style == true
          ff = find(:file_field, locator, options.merge({visible: :all}))
          _update_style(ff, style)
          if ff.visible?
            begin
              ff.set(path)
            ensure
              _reset_style(ff)
            end
          else
            raise ExpectationNotMet, "The style changes in :make_visible did not make the file input visible"
          end
        else
          find(:file_field, locator, options).set(path)
        end
      end

    private
      def _update_style(element, style)
        script = <<-JS
          var el = arguments[0];
          el.capybara_style_cache = el.style.cssText;
          var css = arguments[1];
          for (var prop in css){
            if (css.hasOwnProperty(prop)) {
              el.style[prop] = css[prop]
            }
          }
        JS
        begin
          session.execute_script(script, element, style)
        rescue Capybara::NotSupportedByDriverError
          warn "The :make_visible option is not supported by the current driver - ignoring"
        end
      end

      def _reset_style(element)
        script = <<-JS
          var el = arguments[0];
          if (el.hasOwnProperty('capybara_style_cache')) {
            el.style.cssText = el.capybara_style_cache;
            delete el.capybara_style_cache;
          }
        JS
        begin
          session.execute_script(script, element)
        rescue
        end
      end


      def _check_with_label(selector, checked, locator, options)
        locator, options = nil, locator if locator.is_a? Hash
        allow_label_click = options.delete(:allow_label_click) { Capybara.automatic_label_click }

        synchronize(Capybara::Queries::BaseQuery::wait(options)) do
          begin
            el = find(selector, locator, options)
            el.set(checked)
          rescue => e
            raise unless allow_label_click && catch_error?(e)
            begin
              el ||= find(selector, locator, options.merge(visible: :all))
              label = find(:label, for: el, visible: true)
              label.click unless (el.checked? == checked)
            rescue
              raise e
            end
          end
        end
      end

    end
  end
end
