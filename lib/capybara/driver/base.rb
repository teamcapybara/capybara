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

  def go_back
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#go_back'
  end

  def go_forward
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#go_forward'
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

  def current_window_handle
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#current_window_handle'
  end

  def window_size(handle)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#window_size'
  end

  def resize_window_to(handle, width, height)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#resize_window_to'
  end

  def maximize_window(handle)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#maximize_current_window'
  end

  def close_window(handle)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#close_window'
  end

  def window_handles
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#window_handles'
  end

  def open_new_window
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#open_new_window'
  end

  def switch_to_window(handle)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#switch_to_window'
  end

  def within_window(locator)
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#within_window'
  end

  def no_such_window_error
    raise Capybara::NotSupportedByDriverError, 'Capybara::Driver::Base#no_such_window_error'
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
