# frozen_string_literal: true
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
  # Note that some drivers (e.g. Selenium) support getting size of/resizing/closing only
  #   current window. So if you invoke such method for:
  #
  #   * window that is current, Capybara will make 2 Selenium method invocations
  #     (get handle of current window + get size/resize/close).
  #   * window that is not current, Capybara will make 4 Selenium method invocations
  #     (get handle of current window + switch to given handle + get size/resize/close + switch to original handle)
  #
  class Window
    # @return [String]   a string that uniquely identifies window within session
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
    # Close window.
    #
    # If this method was called for window that is current, then after calling this method
    #   future invocations of other Capybara methods should raise
    #   `session.driver.no_such_window_error` until another window will be switched to.
    #
    # @!macro about_current
    #   If this method was called for window that is not current, then after calling this method
    #   current window shouldn remain the same as it was before calling this method.
    #
    def close
      @driver.close_window(handle)
    end

    ##
    # Get window size.
    #
    # @macro about_current
    # @return [Array<(Integer, Integer)>] an array with width and height
    #
    def size
      @driver.window_size(handle)
    end

    ##
    # Resize window.
    #
    # @macro about_current
    # @param width [String]  the new window width in pixels
    # @param height [String]  the new window height in pixels
    #
    def resize_to(width, height)
      wait_for_stable_size { @driver.resize_window_to(handle, width, height) }
    end

    ##
    # Maximize window.
    #
    # If a particular driver (e.g. headless driver) doesn't have concept of maximizing it
    #   may not support this method.
    #
    # @macro about_current
    #
    def maximize
      wait_for_stable_size { @driver.maximize_window(handle) }
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

    def wait_for_stable_size(seconds=session.config.default_max_wait_time)
      res = yield if block_given?
      prev_size = size
      start_time = Capybara::Helpers.monotonic_time
      while (Capybara::Helpers.monotonic_time - start_time) < seconds
        sleep 0.05
        cur_size = size
        return res if cur_size == prev_size
        prev_size = cur_size
      end
      #TODO raise error in 3.0
      #raise Capybara::WindowError, "Window size not stable."
      warn "Window size not stable in #{seconds} seconds.  This will raise an exception in a future version of Capybara"
      return res
    end

    def raise_unless_current(what)
      unless current?
        raise Capybara::WindowError, "#{what} not current window is not possible."
      end
    end
  end
end
