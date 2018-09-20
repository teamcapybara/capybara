# frozen_string_literal: true

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
