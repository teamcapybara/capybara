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

  def fill_in(locator, options={})
    element = find_field(locator) { |id| "//input[@type='text'][@id='#{id}']" }
    element.value = options[:with]
  end

  def body
    driver.body
  end

private

  def find_field(locator)
    element = find_element(yield(locator), :loose => true)
    element ||= begin
      label = find_element("//label[text()='#{locator}']")
      find_element(yield(label[:for]))
    end
    element
  end

  def find_element(*locators)
    options = if locators.last.is_a?(Hash) then locators.pop else {} end
    locators.each do |locator|
      element = driver.find(locator).first
      return element if element
    end
    raise Webcat::ElementNotFound, "element not found" unless options[:loose]
  end
  
end
