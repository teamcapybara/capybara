# frozen_string_literal: true

require 'capybara/selenium/nodes/chrome_node'

module Capybara::Selenium::Driver::ChromeDriver
  def fullscreen_window(handle)
    within_given_window(handle) do
      begin
        super
      rescue NoMethodError => err
        raise unless err.message =~ /full_screen_window/

        result = bridge.http.call(:post, "session/#{bridge.session_id}/window/fullscreen", {})
        result['value']
      end
    end
  end

  def resize_window_to(handle, width, height)
    super
  rescue Selenium::WebDriver::Error::UnknownError => err
    raise unless err.message =~ /failed to change window state/

    # Chromedriver doesn't wait long enough for state to change when coming out of fullscreen
    # and raises unnecessary error. Wait a bit and try again.
    sleep 0.25
    super
  end

  def reset!
    # Use instance variable directly so we avoid starting the browser just to reset the session
    return unless @browser

    switch_to_window(window_handles.first)
    window_handles.slice(1..-1).each { |win| close_window(win) }
    super
  end

private

  def delete_all_cookies
    execute_cdp('Network.clearBrowserCookies')
  rescue Selenium::WebDriver::Error::UnhandledError, Selenium::WebDriver::Error::WebDriverError
    # If the CDP clear isn't supported do original limited clear
    super
  end

  def execute_cdp(cmd, params = {})
    args = { cmd: cmd, params: params }
    result = bridge.http.call(:post, "session/#{bridge.session_id}/goog/cdp/execute", args)
    result['value']
  end

  def build_node(native_node, initial_cache = {})
    ::Capybara::Selenium::ChromeNode.new(self, native_node, initial_cache)
  end

  def bridge
    browser.send(:bridge)
  end
end
