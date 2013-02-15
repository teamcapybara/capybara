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
      def inspect
        %(#<Capybara::Document>)
      end

      ##
      #
      # @return [String]    The text of the document
      #
      def text
        find(:xpath, '/html').text
      end
      
      def title
        session.driver.title
      end
    end
  end
end
