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

  def evaluate_script(script)
    raise Capybara::NotSupportedByDriverError
  end

  def wait?
    false
  end

  def response_headers
    raise Capybara::NotSupportedByDriverError
  end

  def body
    raise NotImplementedError
  end

  def source
    raise NotImplementedError
  end

  def cleanup!
  end

  def get(*args)
    raise Capybara::NotSupportedByDriverError
  end
  
  def post(*args)
    raise Capybara::NotSupportedByDriverError
  end
  
  def delete(*args)
    raise Capybara::NotSupportedByDriverError
  end
  
  def put(*args)
    raise Capybara::NotSupportedByDriverError    
  end

end
