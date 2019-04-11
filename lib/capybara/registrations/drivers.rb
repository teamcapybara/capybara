# frozen_string_literal: true

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app)
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app)
end

Capybara.register_driver :selenium_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Firefox::Options.new
  browser_options.args << '-headless'
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: browser_options)
end

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--disable-gpu' if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
