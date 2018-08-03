# frozen_string_literal: true

module Capybara
  module Node
    ##
    #
    # A {Capybara::Document} represents an HTML document. Any operation
    # performed on it will be performed on the entire document.
    #
    # @see Capybara::Node
    #
    class Document < Base
      include Capybara::Node::DocumentMatchers

      def inspect
        %(#<Capybara::Document>)
      end

      ##
      #
      # @return [String]    The text of the document
      #
      def text(type = nil, normalize_ws: false)
        find(:xpath, '/html').text(type, normalize_ws: normalize_ws)
      end

      ##
      #
      # @return [String]    The title of the document
      #
      def title
        session.driver.title
      end
    end
  end
end
