module CapybaraPatch

  module DisableWhitespace

    def normalize_whitespace(text)
      Capybara.disable_whitespace_normalization ? text : super
    end

  end

  module WhitespaceAccess

    attr_accessor :disable_whitespace_normalization # Option to globally disable whitespace normalization.

  end

end

module Capybara

  module Helpers

    extend CapybaraPatch::DisableWhitespace

  end

  extend CapybaraPatch::WhitespaceAccess

end
