# frozen_string_literal: true

class Capybara::Selenium::MarionetteNode < Capybara::Selenium::Node
  def click(keys = [], **options)
    super
  rescue ::Selenium::WebDriver::Error::ElementNotInteractableError
    if tag_name == "tr"
      warn "You are attempting to click a table row which has issues in geckodriver/marionette - see https://github.com/mozilla/geckodriver/issues/1228. " \
           "Your test should probably be clicking on a table cell like a user would. Clicking the first cell in the row instead."
      return find_css('th:first-child,td:first-child')[0].click
    end
    raise
  end

  def disabled?
    return true if super

    # workaround for selenium-webdriver/geckodriver reporting elements as enabled when they are nested in disabling elements
    if %w[option optgroup].include? tag_name
      find_xpath("parent::*[self::optgroup or self::select]")[0].disabled?
    else
      !find_xpath("parent::fieldset[@disabled] | ancestor::*[not(self::legend) or preceding-sibling::legend][parent::fieldset[@disabled]]").empty?
    end
  end

  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    path_names = value.to_s.empty? ? [] : value
    native.clear
    Array(path_names).each { |p| native.send_keys(p) }
  end
end
