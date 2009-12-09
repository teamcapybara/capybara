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
  
  def fetch(*paths)
    paths.find do |path|
      result = find(path).first
      return result if result
    end
  end
end