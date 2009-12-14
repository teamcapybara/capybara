class Capybara::Driver::Base
  def visit(path)
    raise "Not implemented"
  end
  
  def find(query)
    raise "Not implemented"
  end
  
  def body
    raise "Not implemented"
  end
  
  def evaluate_script(script)
    raise Capybara::NotSupportedByDriverError
  end
  
  def wait?
    false
  end
end