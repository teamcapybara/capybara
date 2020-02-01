# frozen_string_literal: true

class Capybara::RackTest::CSSHandlers < BasicObject
  include ::Kernel

  def disabled(list)
    list.select { |node| node.has_attribute? 'disabled' }
  end

  def enabled(list)
    list.reject { |node| node.has_attribute? 'disabled' }
  end
end
