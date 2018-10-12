# frozen_string_literal: true

module XPath
  module DSL
    UPPERCASE_LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ'
    LOWERCASE_LETTERS = 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ'

    def lowercase
      method(:translate, UPPERCASE_LETTERS, LOWERCASE_LETTERS)
    end

    def uppercase
      method(:translate, LOWERCASE_LETTERS, UPPERCASE_LETTERS)
    end
  end
end

module Capybara
  module XPathPatches
    module Renderer
      def attribute(current, name)
        return super if name =~ /^[a-zA-Z_:][a-zA-Z0-9_:\.\-]*$/

        "#{current}/attribute::*[local-name(.) = #{string_literal(name)}]"
      end
    end
  end
end

XPath::Renderer.prepend(Capybara::XPathPatches::Renderer)
