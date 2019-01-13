# frozen_string_literal: true

module Capybara
  module Selenium
    module Scroll
      def scroll_by(x, y)
        driver.execute_script <<~JS, self, x, y
          var el = arguments[0];
          if (el.scrollBy){
            el.scrollBy(arguments[1], arguments[2]);
          } else {
            el.scrollTop = el.scrollTop + arguments[2];
            el.scrollLeft = el.scrollLeft + arguments[1];
          }
        JS
      end

      def scroll_to(element, location, position = nil)
        # location, element = element, nil if element.is_a? Symbol
        if element.is_a? Capybara::Selenium::Node
          scroll_element_to_location(element, location)
        elsif location.is_a? Symbol
          scroll_to_location(location)
        else
          scroll_to_coords(*position)
        end
        self
      end

    private

      def scroll_element_to_location(element, location)
        scroll_opts = case location
        when :top
          'true'
        when :bottom
          'false'
        when :center
          "{behavior: 'instant', block: 'center'}"
        else
          raise ArgumentError, "Invalid scroll_to location: #{location}"
        end
        driver.execute_script <<~JS, element
          arguments[0].scrollIntoView(#{scroll_opts})
        JS
      end

      def scroll_to_location(location)
        scroll_y = case location
        when :top
          '0'
        when :bottom
          'arguments[0].scrollHeight'
        when :center
          '(arguments[0].scrollHeight - arguments[0].clientHeight)/2'
        end
        driver.execute_script <<~JS, self
          if (arguments[0].scrollTo){
            arguments[0].scrollTo(0, #{scroll_y});
          } else {
            arguments[0].scrollTop = #{scroll_y};
          }
        JS
      end

      def scroll_to_coords(x, y)
        driver.execute_script <<~JS, self, x, y
          if (arguments[0].scrollTo){
            arguments[0].scrollTo(arguments[1], arguments[2]);
          } else {
            arguments[0].scrollTop = arguments[2];
            arguments[0].scrollLeft = arguments[1];
          }
        JS
      end
    end
  end
end
