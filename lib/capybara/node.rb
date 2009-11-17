class Capybara::Node
  attr_reader :driver, :node

  def initialize(driver, node)
    @driver = driver
    @node = node
  end

  def text
    raise "Not implemented"
  end
  
  def [](name)
    raise "Not implemented"
  end
  
  def value
    self[:value]
  end

  def set(value)
    raise "Not implemented"
  end
  
  def select(option)
    raise "Not implemented"
  end

  def click
    raise "Not implemented"
  end
  
  def tag_name
    raise "Not implemented"
  end
end