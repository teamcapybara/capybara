class Capybara::Selenium::Window < Capybara::Driver::Window
  def size
    dimensions=@driver.browser.manage.window.size
    [dimensions.width, dimensions.height]
  end
  
  def resize(width, height)
    @driver.browser.manage.window.resize_to(width, height)
  end
end