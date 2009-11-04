module Webcat
  class << self
    attr_accessor :debug
    
    def log(message)
      puts message if debug
    end
  end
  
  autoload :Server, 'webcat/server'
  autoload :Session, 'webcat/session'

  module Driver
    autoload :RackTest, 'webcat/rack_test_driver'
    autoload :Culerity, 'webcat/culerity_driver'
  end
end