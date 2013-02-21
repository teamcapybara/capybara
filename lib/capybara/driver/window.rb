class Capybara::Driver::Window
  attr_reader :driver
  
  def initialize(driver)
    @driver=driver
  end
  
  def size
    raise Capybara::NotSupportedByDriverError
  end
  
  def resize(width, height)
    raise Capybara::NotSupportedByDriverError
  end
end