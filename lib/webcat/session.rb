class Webcat::Session
  attr_reader :mode, :app

  def initialize(mode, app)
    @mode = mode
    @app = app
  end

  def driver
    @driver ||= Webcat::Driver::RackTest.new(app) 
  end

  def visit(path)
    driver.visit(path)
  end

  def body
    driver.response.body
  end
end