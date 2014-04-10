module Capybara
  ##
  # The Window class represents a browser window.
  #
  # You can get an instance of the class by calling either of:
  #
  # * {Capybara::Session#windows}
  # * {Capybara::Session#current_window}
  # * {Capybara::Session#window_opened_by}
  # * {Capybara::Session#switch_to_window}
  #
  class Window
    # @return [String]   a string that uniquely identifies window
    attr_reader :handle

    # @return [Capybara::Session] session that this window belongs to
    attr_reader :session

    # @api private
    def initialize(session, handle)
      @session = session
      @driver = session.driver
      @handle = handle
    end

    ##
    # @return [Boolean] whether the window is not closed
    def exists?
      @driver.window_handles.include?(@handle)
    end

    ##
    # @return [Boolean] whether the window is closed
    def closed?
      !exists?
    end

    ##
    # @return [Boolean] whether this window is the window in which commands are being executed
    def current?
      @driver.current_window_handle == @handle
    rescue @driver.no_such_window_error
      false
    end

    ##
    # Close window. Available only for current window.
    # After calling this method future invocations of other Capybara methods should raise
    #   `session.driver.no_such_window_error` until another window will be switched to.
    # @raise [Capybara::WindowError] if invoked not for current window
    #
    def close
      raise_unless_current('Closing')
      @driver.close_current_window
    end

    ##
    # Get window size. Available only for current window.
    # @return [Array<(Fixnum, Fixnum)>] an array with width and height
    # @raise [Capybara::WindowError] if invoked not for current window
    #
    def size
      raise_unless_current('Getting size of')
      @driver.current_window_size
    end

    ##
    # Resize window. Available only for current window.
    # @param width [String]  the new window width in pixels
    # @param height [String]  the new window height in pixels
    # @raise [Capybara::WindowError] if invoked not for current window
    #
    def resize_to(width, height)
      raise_unless_current('Resizing')
      @driver.resize_current_window_to(width, height)
    end

    ##
    # Maximize window. Available only for current window.
    # If a particular driver (e.g. headless driver) doesn't have concept of maximizing it
    #   may not support this method.
    # @raise [Capybara::WindowError] if invoked not for current window
    #
    def maximize
      raise_unless_current('Maximizing')
      @driver.maximize_current_window
    end

    def eql?(other)
      other.kind_of?(self.class) && @session == other.session && @handle == other.handle
    end
    alias_method :==, :eql?

    def hash
      @session.hash ^ @handle.hash
    end

    def inspect
      "#<Window @handle=#{@handle.inspect}>"
    end

    private

    def raise_unless_current(what)
      unless current?
        raise Capybara::WindowError, "#{what} not current window is not possible."
      end
    end
  end
end
