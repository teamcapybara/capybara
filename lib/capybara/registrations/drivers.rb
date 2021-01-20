# frozen_string_literal: true

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app)
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app)
end

Capybara.register_driver :selenium_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Firefox::Options.new

  if browser_options.respond_to?(:headless!)
    browser_options.headless!
  else
    browser_options.args << '-headless'
  end

  if version >= Gem::Version.new('4.0.0.alpha6')
    Capybara::Selenium::Driver.new(app, browser: :firefox, capabilities: browser_options)
  else
    Capybara::Selenium::Driver.new(app, browser: :firefox, options: browser_options)
  end
end

Capybara.register_driver :selenium_chrome do |app|
  version = Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    if opts.respond_to?(:add_argument)
      opts.add_argument('--disable-site-isolation-trials')
    else
      opts.args << '--disable-site-isolation-trials'
    end
  end

  if version >= Gem::Version.new('4.0.0.alpha6')
    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: browser_options)
  else
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end
end

Capybara.register_driver :selenium_chrome_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
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

  if version >= Gem::Version.new('4.0.0.alpha6')
    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: browser_options)
  else
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end
end
