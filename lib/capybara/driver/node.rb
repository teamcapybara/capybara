# frozen_string_literal: true

module Capybara
  module Driver
    class Node
      attr_reader :driver, :native, :initial_cache

      NON_BREAKING_SPACE = "\u00a0"
      LINE_SEPERATOR = "\u2028"
      PARAGRAPH_SEPERATOR = "\u2029"

      BREAKING_SPACES = "[[:space:]&&[^#{NON_BREAKING_SPACE}]]"

      SQUEEZED_SPACES = "\ \n\f\t\v#{LINE_SEPERATOR}#{PARAGRAPH_SEPERATOR}"
      LEADING_SPACES = /\A#{BREAKING_SPACES}+/
      TRAILING_SPACES = /#{BREAKING_SPACES}+\z/

      ZERO_WIDTH_SPACE = "\u200b"
      LEFT_TO_RIGHT_MARK = "\u200e"
      RIGHT_TO_LEFT_MARK = "\u200f"

      REMOVED_CHARACTERS = [ZERO_WIDTH_SPACE, LEFT_TO_RIGHT_MARK, RIGHT_TO_LEFT_MARK].join

      EMPTY_LINES = /[\ \n]*\n[\ \n]*/

      def initialize(driver, native, initial_cache = {})
        @driver = driver
        @native = native
        @initial_cache = initial_cache
      end

      def all_text
        raise NotImplementedError
      end

      def visible_text
        raise NotImplementedError
      end

      def [](name)
        raise NotImplementedError
      end

      def value
        raise NotImplementedError
      end

      def style(styles)
        raise NotImplementedError
      end

      # @param value [String, Array] Array is only allowed if node has 'multiple' attribute
      # @param options [Hash] Driver specific options for how to set a value on a node
      def set(value, **options)
        raise NotImplementedError
      end

      def select_option
        raise NotImplementedError
      end

      def unselect_option
        raise NotImplementedError
      end

      def click(keys = [], **options)
        raise NotImplementedError
      end

      def right_click(keys = [], **options)
        raise NotImplementedError
      end

      def double_click(keys = [], **options)
        raise NotImplementedError
      end

      def send_keys(*args)
        raise NotImplementedError
      end

      def hover
        raise NotImplementedError
      end

      def drag_to(element, **options)
        raise NotImplementedError
      end

      def drop(*args)
        raise NotImplementedError
      end

      def scroll_by(x, y)
        raise NotImplementedError
      end

      def scroll_to(element, alignment, position = nil)
        raise NotImplementedError
      end

      def tag_name
        raise NotImplementedError
      end

      def visible?
        raise NotImplementedError
      end

      def obscured?
        raise NotImplementedError
      end

      def checked?
        raise NotImplementedError
      end

      def selected?
        raise NotImplementedError
      end

      def disabled?
        raise NotImplementedError
      end

      def readonly?
        !!self[:readonly]
      end

      def multiple?
        !!self[:multiple]
      end

      def rect
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#rect'
      end

      def path
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#path'
      end

      def trigger(event)
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#trigger'
      end

      def shadow_root
        raise NotSupportedByDriverError, 'Capybara::Driver::Node#shadow_root'
      end

      def inspect
        %(#<#{self.class} tag="#{tag_name}" path="#{path}">)
      rescue NotSupportedByDriverError
        %(#<#{self.class} tag="#{tag_name}">)
      end

      def ==(other)
        eql?(other) || (other.respond_to?(:native) && native == other.native)
      end

      protected

      def normalize_spacing(text)
        text
          .delete(REMOVED_CHARACTERS)
          .tr(SQUEEZED_SPACES, ' ')
          .squeeze(' ')
          .sub(LEADING_SPACES, '')
          .sub(TRAILING_SPACES, '')
          .tr(NON_BREAKING_SPACE, ' ')
      end

      def normalize_visible_spacing(text)
        text
          .squeeze(' ')
          .gsub(EMPTY_LINES, "\n")
          .sub(LEADING_SPACES, '')
          .sub(TRAILING_SPACES, '')
          .tr(NON_BREAKING_SPACE, ' ')
      end
    end
  end
end
