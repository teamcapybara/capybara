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
    when :selenium
      Webcat::Driver::Selenium.new(app)
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
    has_xpath?("//*[contains(child::text(),'#{content}')]")
  end
  
  def has_xpath?(path, options={})
    if options[:count]
      find(path).size == options[:count]
    else
      find(path).size > 0
    end
  end
  
  def within(scope)
    scopes.push(scope)
    yield
    scopes.pop
  end
  
  def save_and_open_page
    require 'webcat/save_and_open_page'
    Webcat::SaveAndOpenPage.save_and_open_page(body)
  end

private

  def current_scope
    scopes.join('')
  end

  def scopes
    @scopes ||= []
  end

  def find_link(locator)
    link = find_element("//a[@id='#{locator}']", "//a[contains(.,'#{locator}')]", "//a[@title='#{locator}']")
    raise Webcat::ElementNotFound, "no button with value or id '#{locator}' found" unless link
    link
  end

  def find_button(locator)
    button = find_element(
      "//input[@type='submit'][@id='#{locator}']",
      "//input[@type='submit'][@value='#{locator}']",
      "//input[@type='image'][@id='#{locator}']",
      "//input[@type='image'][@value='#{locator}']"
    )
    raise Webcat::ElementNotFound, "no link with title, id or text '#{locator}' found" unless button
    button
  end

  def find_field(locator, *kinds)
    field = find_field_by_id(locator, *kinds) || find_field_by_label(locator, *kinds)
    raise Webcat::ElementNotFound, "no field of kind #{kinds.inspect} with id or'#{locator}' found" unless field
    field
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
      element = find(path.call(locator)).first
      return element if element
    end
    return nil
  end

  def find_field_by_label(locator, *kinds)
    kinds.each do |kind|
      label = find("//label[contains(.,'#{locator}')]").first
      if label
        element = find_field_by_id(label[:for], kind)
        return element if element
      end
    end
    return nil
  end

  def find_element(*locators)
    locators.each do |locator|
      element = find(locator).first
      return element if element
    end
    return nil
  end
  
  def find(locator)
    locator = current_scope.to_s + locator
    driver.find(locator)
  end
  
end
