module Capybara
  module Node
    class Simple
      include Capybara::Node::Finders
      include Capybara::Node::Matchers

      attr_reader :native

      def initialize(native)
        native = Nokogiri::HTML(native) if native.is_a?(String)
        @native = native
      end

      def text
        native.text
      end

      def [](name)
        attr_name = name.to_s
        if attr_name == 'value'
          value
        elsif 'input' == tag_name and 'checkbox' == native[:type] and 'checked' == attr_name
          native['checked'] == 'checked'
        else
          native[attr_name]
        end
      end

      def tag_name
        native.node_name
      end

      def path
        native.path
      end

      def value
        if tag_name == 'textarea'
          native.content
        elsif tag_name == 'select'
          if native['multiple'] == 'multiple'
            native.xpath(".//option[@selected='selected']").map { |option| option[:value] || option.content  }
          else
            option = native.xpath(".//option[@selected='selected']").first || native.xpath(".//option").first
            option[:value] || option.content if option
          end
        else
          native[:value]
        end
      end

      def visible?
        native.xpath("./ancestor-or-self::*[contains(@style, 'display:none') or contains(@style, 'display: none')]").size == 0
      end

    protected

      def find_in_base(xpath)
        native.xpath(xpath).map { |node| self.class.new(node) }
      end

      def convert_elements(elements)
        elements
      end

      def wait?
        false
      end
    end
  end
end
