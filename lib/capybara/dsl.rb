require 'capybara'

module Capybara
  module DSL

    ##
    #
    # Shortcut to working in a different session.
    #
    def using_session(name, &block)
      Capybara.using_session(name, &block)
    end

    ##
    #
    # Shortcut to using a different wait time.
    #
    def using_wait_time(seconds, &block)
      Capybara.using_wait_time(seconds, &block)
    end

    ##
    #
    # Shortcut to accessing the current session.
    #
    #     class MyClass
    #       include Capybara::DSL
    #
    #       def has_header?
    #         page.has_css?('h1')
    #       end
    #     end
    #
    # @return [Capybara::Session] The current session object
    #
    def page
      Capybara.current_session
    end

    ##
    #
    # If using a driver that runs a rack server, check for errors will raise any
    # errors that were not handled inside the application.
    #
    # @return [NilClass] If no errors were raised
    def check_for_errors
      return unless page.driver.respond_to?(:rack_server)
      e = page.driver.rack_server.last_error
      raise e if e
    end

    Session::DSL_METHODS.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{method}(*args, &block)
          check_for_errors
          page.#{method}(*args, &block)
        end
      RUBY
    end
  end

  extend(Capybara::DSL)
end
