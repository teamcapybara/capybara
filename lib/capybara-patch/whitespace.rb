module Capybara

  module WhitespaceAccess

    attr_accessor :disable_whitespace_normalization # Option to globally disable whitespace normalization.

  end

  module Helpers

    private

    module DisableWhitespace

      def normalize_whitespace(text)
        Capybara.disable_whitespace_normalization ? text : super
      end

    end

    extend DisableWhitespace

  end

  extend WhitespaceAccess

end
