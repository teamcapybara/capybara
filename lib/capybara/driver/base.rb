class Capybara::Driver::Base
  def current_url
    raise NotImplementedError
  end

  def visit(path)
    raise NotImplementedError
  end

  def find_xpath(query)
    raise NotImplementedError
  end
  
  def find_css(query)
    raise NotImplementedError
  end

  def html
    raise NotImplementedError
  end

  def execute_script(script)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#execute_script'
  end

  def evaluate_script(script)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#evaluate_script'
  end

  def save_screenshot(path, options={})
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#save_screenshot'
  end

  def response_headers
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#response_headers'
  end

  def status_code
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#status_code'
  end

  def within_frame(frame_handle)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#within_frame'
  end

  def within_window(handle)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#within_window'
  end

  def invalid_element_errors
    []
  end

  def wait?
    false
  end

  def reset!
  end

  def needs_server?
    false
  end
end
