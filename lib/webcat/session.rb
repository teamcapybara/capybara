class Webcat::Session
  attr_reader :mode, :app

  def initialize(mode, app)
    @mode = mode
    @app = app
  end

  def driver
    @driver ||= case mode
    when :rack_test
      Webcat::Driver::RackTest.new(app)
    when :culerity
      Webcat::Driver::Culerity.new(app)
    else
      raise Webcat::DriverNotFoundError, "no driver called #{mode} was found"
    end
  end

  def visit(path)
    driver.visit(path)
  end

  def body
    driver.body
  end
end