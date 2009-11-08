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
  
  def click_link(locator)
    find_element("//a[@id='#{locator}']", %{//a[text()="#{locator}"]}, %{//a[@title="#{locator}"]}).click
  end

  def click_button(locator)
    find_element("//input[@type='submit'][@id='#{locator}']", "//input[@type='submit'][@value='#{locator}']").click
  end

  def body
    driver.body
  end

private

  def find_element(*locators)
    locators.each do |locator|
      element = driver.find(locator).first
      return element if element
    end
    raise Webcat::ElementNotFound, "element not found"
  end
  
end
