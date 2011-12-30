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

    Session::DSL_METHODS.each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{method}(*args, &block)
          page.#{method}(*args, &block)
        end
      RUBY
    end
  end

  extend(Capybara::DSL)
end
