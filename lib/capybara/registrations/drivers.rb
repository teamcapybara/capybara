# frozen_string_literal: true

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app)
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app)
end

Capybara.register_driver :selenium_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = ::Selenium::WebDriver::Firefox::Options.new.tap do |opts|
    if browser_options.respond_to?(:headless!)
      opts.headless!
    else
      opts.args << '-headless'
    end
  end
  Capybara::Selenium::Driver.new(app, **Hash[:browser => :firefox, options_key => browser_options])
end

Capybara.register_driver :selenium_chrome do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    if opts.respond_to?(:add_argument)
      opts.add_argument('--disable-site-isolation-trials')
    else
      opts.args << '--disable-site-isolation-trials'
    end
  end

  Capybara::Selenium::Driver.new(app, **Hash[:browser => :firefox, options_key => browser_options])
end

Capybara.register_driver :selenium_chrome_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    if opts.respond_to?(:headless!)
      opts.headless!
    else
      opts.args << '--headless'
    end
    opts.args << '--disable-gpu' if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
  end

  Capybara::Selenium::Driver.new(app, **Hash[:browser => :firefox, options_key => browser_options])
end
