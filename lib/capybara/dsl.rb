require 'capybara'

module Capybara
  def self.included(base)
    base.send(:include, Capybara::DSL)
    warn "`include Capybara` is deprecated please use `include Capybara::DSL` instead."
  end

  class << self
    attr_writer :default_driver, :current_driver, :javascript_driver, :session_name

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
    # Yield a block using a specific driver
    #
    def using_driver(driver)
      previous_driver = Capybara.current_driver
      Capybara.current_driver = driver
      yield
    ensure
      @current_driver = previous_driver
    end

    ##
    #
    # Yield a block using a specific wait time
    #
    def using_wait_time(seconds)
      previous_wait_time = Capybara.default_wait_time
      Capybara.default_wait_time = seconds
      yield
    ensure
      Capybara.default_wait_time = previous_wait_time
    end

    ##
    #
    # The current Capybara::Session base on what is set as Capybara.app and Capybara.current_driver
    #
    # @return [Capybara::Session]     The currently used session
    #
    def current_session
      session_pool["#{current_driver}:#{session_name}:#{app.object_id}"] ||= Capybara::Session.new(current_driver, app)
    end

    ##
    #
    # Reset sessions, cleaning out the pool of sessions. This will remove any session information such
    # as cookies.
    #
    def reset_sessions!
      session_pool.each { |mode, session| session.reset! }
    end
    alias_method :reset!, :reset_sessions!

    ##
    #
    # The current session name.
    #
    # @return [Symbol]    The name of the currently used session.
    #
    def session_name
      @session_name ||= :default
    end

    ##
    #
    # Yield a block using a specific session name.
    #
    def using_session(name)
      self.session_name = name
      yield
    ensure
      self.session_name = :default
    end

  private

    def session_pool
      @session_pool ||= {}
    end
  end

  module DSL

    ##
    #
    # Shortcut to working in a different session. This is useful when Capybara is included
    # in a class or module.
    #
    def using_session(name, &block)
      Capybara.using_session(name, &block)
    end

    ##
    #
    # Shortcut to working in a different session. This is useful when Capybara is included
    # in a class or module.
    #
    def using_wait_time(seconds, &block)
      Capybara.using_wait_time(seconds, &block)
    end

    ##
    #
    # Shortcut to accessing the current session. This is useful when Capybara is included in a
    # class or module.
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
