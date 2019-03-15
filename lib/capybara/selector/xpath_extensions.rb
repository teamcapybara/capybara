# frozen_string_literal: true

module XPath
  class Renderer
    def join(*expressions)
      expressions.join('/')
    end
  end
end
