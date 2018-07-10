# frozen_string_literal: true

class Capybara::Selenium::MarionetteNode < Capybara::Selenium::Node
  def click(keys = [], **options)
    super
  rescue ::Selenium::WebDriver::Error::ElementNotInteractableError
    if tag_name == 'tr'
      warn 'You are attempting to click a table row which has issues in geckodriver/marionette - see https://github.com/mozilla/geckodriver/issues/1228. ' \
           'Your test should probably be clicking on a table cell like a user would. Clicking the first cell in the row instead.'
      return find_css('th:first-child,td:first-child')[0].click
    end
    raise
  end

  def disabled?
    # Not sure exactly what version of FF fixed the below issue, but it is definitely fixed in 61+
    return super unless driver.browser.capabilities[:browser_version].to_f < 61.0

    return true if super
    # workaround for selenium-webdriver/geckodriver reporting elements as enabled when they are nested in disabling elements
    if %w[option optgroup].include? tag_name
      find_xpath('parent::*[self::optgroup or self::select]')[0].disabled?
    else
      !find_xpath('parent::fieldset[@disabled] | ancestor::*[not(self::legend) or preceding-sibling::legend][parent::fieldset[@disabled]]').empty?
    end
  end

  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    path_names = value.to_s.empty? ? [] : value
    native.clear
    Array(path_names).each do |path|
      unless driver.browser.respond_to?(:upload)
        if (fd = bridge.file_detector)
          local_file = fd.call([path])
          path = upload(local_file) if local_file
        end
      end
      native.send_keys(path)
    end
  end

private

  def bridge
    driver.browser.send(:bridge)
  end

  def upload(local_file)
    unless File.file?(local_file)
      raise Error::WebDriverError, "you may only upload files: #{local_file.inspect}"
    end

    result = bridge.http.call(:post, "session/#{bridge.session_id}/file", file: Selenium::WebDriver::Zipper.zip_file(local_file))
    result['value']
  end
end
