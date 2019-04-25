# frozen_string_literal: true

require 'capybara/selenium/extensions/html5_drag'

class Capybara::Selenium::IENode < Capybara::Selenium::Node
  def disabled?
    driver.evaluate_script("arguments[0].msMatchesSelector(':disabled, select:disabled *')", self)
  end
end
