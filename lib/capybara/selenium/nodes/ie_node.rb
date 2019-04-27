# frozen_string_literal: true

require 'capybara/selenium/extensions/html5_drag'

class Capybara::Selenium::IENode < Capybara::Selenium::Node
  def disabled?
    # TODO: Doesn't work for a bunch of cases - need to get IE running to see if it can be done like this
    # driver.evaluate_script("arguments[0].msMatchesSelector(':disabled, select:disabled *')", self)
    super
  end
end
