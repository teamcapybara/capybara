module Webcat
  module Selenium

    class SeleniumRCServer
      unless Kernel.respond_to?(:silence_stream)
        def silence_stream(stream)
          old_stream = stream.dup
          stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
          stream.sync = true
          yield
        ensure
          stream.reopen(old_stream)
        end
      end

      def booted?
        @booted || false
      end

      def boot
        return if booted?
        silence_stream(STDOUT) do
          remote_control.start :background => true
        end
        wait
        @booted = true
        at_exit do
          silence_stream(STDOUT) do
            remote_control.stop
          end
        end
      end

      def remote_control
        return @remote_control if @remote_control

        @remote_control = ::Selenium::RemoteControl::RemoteControl.new("0.0.0.0", 5041, 15)
        @remote_control.jar_file = jar_path

        return @remote_control
      end

      def jar_path
        File.expand_path("selenium-server.jar", File.dirname(__FILE__))
      end

      def wait
        return true
        $stderr.print "==> Waiting for Selenium RC server on port #{Webrat.configuration.selenium_server_port}... "
        TCPSocket.wait_for_service_with_timeout(:host => "localhost", :port => 5041, :timeout => 15)
        $stderr.print "Ready!\n"
      rescue SocketError
        $stderr.puts "==> Failed to boot the Selenium RC server... exiting!"
        exit
      end

    end

  end
end

