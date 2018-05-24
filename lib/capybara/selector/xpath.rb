# frozen_string_literal: true

require 'xpath'

# Patch XPath to allow a nil condition in where
module XPath
  class Renderer
    undef :where if method_defined?(:where)

    def where(on, condition)
      condition = condition.to_s
      if !condition.empty?
        "#{on}[#{condition}]"
      else
        on.to_s
      end
    end
  end

  module DSL
    def ends_with(suffix)
      function(:substring, current, function(:'string-length', current).minus(function(:'string-length', suffix)).plus(1)) == suffix
    end
  end
end
