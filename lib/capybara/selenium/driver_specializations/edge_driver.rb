# frozen_string_literal: true

require 'capybara/selenium/nodes/edge_node'

module Capybara::Selenium::Driver::EdgeDriver
  def fullscreen_window(handle)
    return super if edgedriver_version < 75

    within_given_window(handle) do
      begin
        super
      rescue NoMethodError => e
        raise unless e.message.match?(/full_screen_window/)

        result = bridge.http.call(:post, "session/#{bridge.session_id}/window/fullscreen", {})
        result['value']
      end
    end
  end

  def resize_window_to(handle, width, height)
    super
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.match?(/failed to change window state/)

    # Chromedriver doesn't wait long enough for state to change when coming out of fullscreen
    # and raises unnecessary error. Wait a bit and try again.
    sleep 0.25
    super
  end

  def reset!
    return super if edgedriver_version < 75
    # Use instance variable directly so we avoid starting the browser just to reset the session
    return unless @browser

    switch_to_window(window_handles.first)
    window_handles.slice(1..-1).each { |win| close_window(win) }

    timer = Capybara::Helpers.timer(expire_in: 10)
    begin
      @browser.navigate.to('about:blank')
      clear_storage unless uniform_storage_clear?
      wait_for_empty_page(timer)
    rescue *unhandled_alert_errors
      accept_unhandled_reset_alert
      retry
    end

    execute_cdp('Storage.clearDataForOrigin', origin: '*', storageTypes: storage_types_to_clear)
  end

  def download_path=(path)
    if @browser.respond_to?(:download_path=)
      @browser.download_path = path
    else
      # Not yet implemented in seleniun-webdriver for edge so do it ourselves
      execute_cdp('Page.setDownloadBehavior', behavior: 'allow', downloadPath: path)
    end
  end

private

  def storage_types_to_clear
    types = ['cookies']
    types << 'local_storage' if clear_all_storage?
    types.join(',')
  end

  def clear_all_storage?
    options.values_at(:clear_session_storage, :clear_local_storage).none? { |s| s == false }
  end

  def uniform_storage_clear?
    clear = options.values_at(:clear_session_storage, :clear_local_storage)
    clear.all? { |s| s == false } || clear.none? { |s| s == false }
  end

  def clear_storage
    # Chrome errors if attempt to clear storage on about:blank
    # In W3C mode it crashes chromedriver
    url = current_url
    super unless url.nil? || url.start_with?('about:')
  end

  def delete_all_cookies
    return super if edgedriver_version < 75

    execute_cdp('Network.clearBrowserCookies')
  rescue *cdp_unsupported_errors
    # If the CDP clear isn't supported do original limited clear
    super
  end

  def cdp_unsupported_errors
    @cdp_unsupported_errors ||= [Selenium::WebDriver::Error::WebDriverError]
  end

  def execute_cdp(cmd, params = {})
    args = { cmd: cmd, params: params }
    result = bridge.http.call(:post, "session/#{bridge.session_id}/goog/cdp/execute", args)
    result['value']
  end

  def build_node(native_node, initial_cache = {})
    ::Capybara::Selenium::EdgeNode.new(self, native_node, initial_cache)
  end

  def bridge
    browser.send(:bridge)
  end

  def edgedriver_version
    @edgedriver_version ||= begin
      caps = browser.capabilities
      caps['chrome']&.fetch('chromedriverVersion', nil).to_f
    end
  end
end

Capybara::Selenium::Driver.register_specialization :edge, Capybara::Selenium::Driver::EdgeDriver
Capybara::Selenium::Driver.register_specialization :edge_chrome, Capybara::Selenium::Driver::EdgeDriver
