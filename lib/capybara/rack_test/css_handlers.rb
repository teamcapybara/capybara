class Capybara::RackTest::CSSHandlers < BasicObject
  include ::Kernel

  def disabled list
    list.find_all { |node| node.has_attribute? 'disabled' }
  end
  def enabled list
    list.find_all { |node| !node.has_attribute? 'disabled' }
  end
  def checked list
    list.find_all { |node| node.has_attribute? 'checked' or node.has_attribute? 'selected' }
  end
end
