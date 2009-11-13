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
    find_link(locator).click
  end

  def click_button(locator)
    find_button(locator).click
  end

  def fill_in(locator, options={})
    find_field(locator, :text_field, :text_area, :password_field).set(options[:with])
  end
  
  def choose(locator)
    find_field(locator, :radio).set(true)
  end
  
  def set_hidden_field(locator, options={})
    find_field(locator, :hidden_field).set(options[:to])
  end
  
  def check(locator)
    find_field(locator, :checkbox).set(true)
  end
  
  def uncheck(locator)
    find_field(locator, :checkbox).set(false)
  end
  
  def select(value, options={})
    find_field(options[:from], :select).select(value)
  end
  
  def attach_file(locator, path)
    find_field(locator, :file_field).set(path)
  end

  def body
    driver.body
  end
  
  def has_content?(content)
    driver.find("//*[contains(child::text(),'#{content}')]").size > 0
  end

private

  def find_link(locator)
    find_element("//a[@id='#{locator}']", %{//a[text()="#{locator}"]}, %{//a[@title="#{locator}"]})
  end

  def find_button(locator)
    find_element(
      "//input[@type='submit'][@id='#{locator}']",
      "//input[@type='submit'][@value='#{locator}']",
      "//input[@type='image'][@id='#{locator}']",
      "//input[@type='image'][@value='#{locator}']"
    )
  end

  def find_field(locator, *kinds)
    find_field_by_id(locator, *kinds) or find_field_by_label(locator, *kinds)
  end

  FIELDS_PATHS = {
    :text_field => proc { |id| "//input[@type='text'][@id='#{id}']" },
    :text_area => proc { |id| "//textarea[@id='#{id}']" },
    :password_field => proc { |id| "//input[@type='password'][@id='#{id}']" },
    :radio => proc { |id| "//input[@type='radio'][@id='#{id}']" },
    :hidden_field => proc { |id| "//input[@type='hidden'][@id='#{id}']" },
    :checkbox => proc { |id| "//input[@type='checkbox'][@id='#{id}']" },
    :select => proc { |id| "//select[@id='#{id}']" },
    :file_field => proc { |id| "//input[@type='file'][@id='#{id}']" }
  }

  def find_field_by_id(locator, *kinds)
    kinds.each do |kind|
      path = FIELDS_PATHS[kind]
      element = driver.find(path.call(locator)).first
      return element if element
    end
    return nil
  end

  def find_field_by_label(locator, *kinds)
    kinds.each do |kind|
      label = driver.find("//label[text()='#{locator}']").first
      if label
        element = find_field_by_id(label[:for], kind)
        return element if element
      end
    end
    return nil
  end

  def find_element(*locators)
    locators.each do |locator|
      element = driver.find(locator).first
      return element if element
    end
    raise Webcat::ElementNotFound, "element not found"
  end
  
end
