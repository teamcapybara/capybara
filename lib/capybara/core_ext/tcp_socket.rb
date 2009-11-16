class TCPSocket
  def self.wait_for_service_with_timeout(options)
    start_time = Time.now

    until listening_service?(options)
      verbose_wait

      if options[:timeout] && (Time.now > start_time + options[:timeout])
        raise SocketError.new("Socket did not open within #{options[:timeout]} seconds")
      end
    end
  end

  def self.wait_for_service_termination_with_timeout(options)
    start_time = Time.now

    while listening_service?(options)
      verbose_wait

      if options[:timeout] && (Time.now > start_time + options[:timeout])
        raise SocketError.new("Socket did not terminate within #{options[:timeout]} seconds")
      end
    end
  end
end

