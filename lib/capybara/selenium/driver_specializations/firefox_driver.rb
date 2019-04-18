# frozen_string_literal: true

require 'capybara/selenium/nodes/firefox_node'

module Capybara::Selenium::Driver::FirefoxDriver
  def self.extended(driver)
    driver.extend Capybara::Selenium::Driver::W3CFirefoxDriver if w3c?(driver)
  end

  def self.w3c?(driver)
    (defined?(Selenium::WebDriver::VERSION) && (Selenium::WebDriver::VERSION.to_f >= 4)) ||
      driver.browser.capabilities.is_a?(::Selenium::WebDriver::Remote::W3C::Capabilities)
  end
end

module Capybara::Selenium::Driver::W3CFirefoxDriver
  class << self
    def extended(driver)
      require 'capybara/selenium/patches/pause_duration_fix' if pause_broken?(driver.browser)
    end

    def pause_broken?(sel_driver)
      sel_driver.capabilities['moz:geckodriverVersion']&.start_with?('0.22.')
    end
  end

  def resize_window_to(handle, width, height)
    within_given_window(handle) do
      # Don't set the size if already set - See https://github.com/mozilla/geckodriver/issues/643
      if window_size(handle) == [width, height]
        {}
      else
        super
      end
    end
  end

  def reset!
    # Use instance variable directly so we avoid starting the browser just to reset the session
    return unless @browser

    switch_to_window(window_handles.first)
    window_handles.slice(1..-1).each { |win| close_window(win) }
    super
  end

  def refresh
    # Accept any "will repost content" confirmation that occurs
    accept_modal :confirm, wait: 0.1 do
      super
    end
  rescue Capybara::ModalNotFound # rubocop:disable Lint/HandleExceptions
    # No modal was opened - page has refreshed - ignore
  end

  def switch_to_frame(frame)
    return super unless frame == :parent

    # geckodriver/firefox has an issue if the current frame is removed from within it
    # so we have to move to the default_content and iterate back through the frames
    handles = @frame_handles[current_window_handle]
    browser.switch_to.default_content
    handles.tap(&:pop).each { |fh| browser.switch_to.frame(fh) }
  end

private

  def build_node(native_node, initial_cache = {})
    ::Capybara::Selenium::FirefoxNode.new(self, native_node, initial_cache)
  end
end

Capybara::Selenium::Driver.register_specialization :firefox, Capybara::Selenium::Driver::FirefoxDriver
