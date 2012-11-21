class Capybara::Driver::Base
  def current_url
    raise NotImplementedError
  end

  def visit(path)
    raise NotImplementedError
  end

  def find(query)
    raise NotImplementedError
  end

  def html
    raise NotImplementedError
  end

  def execute_script(script)
    raise Capybara::NotSupportedByDriverError
  end

  def evaluate_script(script)
    raise Capybara::NotSupportedByDriverError
  end

  def save_screenshot(path, options={})
    raise Capybara::NotSupportedByDriverError
  end

  def response_headers
    raise Capybara::NotSupportedByDriverError
  end

  def status_code
    raise Capybara::NotSupportedByDriverError
  end

  def within_frame(frame_id)
    raise Capybara::NotSupportedByDriverError
  end

  def within_window(handle)
    raise Capybara::NotSupportedByDriverError
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
