module CapybaraPatch

  module Threaded

    # Returns true if this is a server that uses forks (ex. Unicorn). If true,
    # it is assumed elsewhere that two things are true:
    #   1. a new thread for the server is not needed
    #   2. inter-thread communication (ex. bubbling up exceptions to the test
    #   thread) is not available
    def fork?
      defined?(Unicorn)
    end

    # Return the recorded error from the Rack middleware. That is, unless this
    # is a forked process, in which case inter-thread communication is not
    # available.
    def error
      super unless fork?
    end

    def boot
      if responsive?
        self
      else
        Capybara::Server.ports[@app.object_id] = @port

        wait = Wait.new(:delay => 5, :attempts => 3)
        if fork?
          initialize_server
          wait.until do
            responsive?
          end
        else
          @server_thread = Thread.new do
            Capybara.server.call(@middleware, @port)
          end
          wait.until do
            @server_thread.join(0.1)
            responsive?
          end
        end
      end
    rescue Wait::TimeoutError
      raise "Rack application timed out during boot"
    end

    private

    # Initializes the server held within the Capybara.server Proc.
    def initialize_server
      Capybara.server.call(@middleware, @port)
    end

  end

end

module Capybara

  class Server

    include CapybaraPatch::Threaded

  end

end
