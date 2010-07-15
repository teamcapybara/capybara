require 'capybara'

module Capybara
  class << self
    attr_writer :default_driver, :current_driver, :javascript_driver

    attr_accessor :app

    ##
    #
    # @return [Symbol]    The name of the driver to use by default
    #
    def default_driver
      @default_driver || :rack_test
    end

    ##
    #
    # @return [Symbol]    The name of the driver currently in use
    #
    def current_driver
      @current_driver || default_driver
    end
    alias_method :mode, :current_driver

    ##
    #
    # @return [Symbol]    The name of the driver used when JavaScript is needed
    #
    def javascript_driver
      @javascript_driver || :selenium
    end

    ##
    #
    # Use the default driver as the current driver
    #
    def use_default_driver
      @current_driver = nil
    end

    ##
    #
    # The current Capybara::Session base on what is set as Capybara.app and Capybara.current_driver
    #
    # @return [Capybara::Session]     The currently used session
    #
    def current_session
      session_pool["#{current_driver}#{app.object_id}"] ||= Capybara::Session.new(current_driver, app)
    end

    ##
    #
    # Reset sessions, cleaning out the pool of sessions. This will remove any session information such
    # as cookies.
    #
    def reset_sessions!
      session_pool.each { |mode, session| session.cleanup! }
      @session_pool = nil
    end

  private

    def session_pool
      @session_pool ||= {}
    end
  end

  extend(self)

  ##
  #
  # Shortcut to accessing the current session. This is useful when Capybara is included in a
  # class or module.
  #
  #     class MyClass
  #       include Capybara
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
