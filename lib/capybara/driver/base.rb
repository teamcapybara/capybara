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

  def source
    raise NotImplementedError
  end

  def body
    raise NotImplementedError
  end

  def execute_script(script)
    raise Capybara::NotSupportedByDriverError
  end

  def evaluate_script(script)
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

  def wait_until(*args)
  end

  def reset!
  end

  def has_shortcircuit_timeout?
    false
  end

end
