module Webcat
  class << self
    attr_writer :default_driver, :current_driver

    def default_driver
      @default_driver || :rack_test
    end

    def current_driver
      @current_driver || default_driver 
    end
    alias_method :mode, :current_driver

    def use_default_driver
      @current_driver = nil 
    end

    def session_pool
      @session_pool ||= {}
    end
  end

  extend(self)

  attr_accessor :app

  def current_session
    driver = Webcat.current_driver
    Webcat.session_pool["#{driver}#{app.object_id}"] ||= Webcat::Session.new(driver, app)
  end

  SESSION_METHODS = [
    :visit, :body, :click_link, :click_button, :fill_in, :choose,
    :set_hidden_field, :check, :uncheck, :attach_file, :select
  ]
  SESSION_METHODS.each do |method|
    class_eval <<-RUBY, __FILE__, __LINE__+1
      def #{method}(*args, &block)
        current_session.#{method}(*args, &block)
      end
    RUBY
  end

end
