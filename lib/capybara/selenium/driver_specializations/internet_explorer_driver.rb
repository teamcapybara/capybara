# frozen_string_literal: true

require 'capybara/selenium/nodes/ie_node'

module Capybara::Selenium::Driver::InternetExplorerDriver
  def switch_to_frame(frame)
    return super unless frame == :parent

    # iedriverserver has an issue if the current frame is removed from within it
    # so we have to move to the default_content and iterate back through the frames
    handles = @frame_handles[current_window_handle]
    browser.switch_to.default_content
    handles.tap(&:pop).each { |fh| browser.switch_to.frame(fh.native) }
  end

private

  def clear_storage
    clear_session_storage unless !!options[:clear_session_storage]
    clear_local_storage unless !!options[:clear_local_storage]
  rescue Selenium::WebDriver::Error::JavascriptError
    # session/local storage may not be available if on non-http pages (e.g. about:blank)
  end

  def build_node(native_node, initial_cache = {})
    ::Capybara::Selenium::IENode.new(self, native_node, initial_cache)
  end
end

module Capybara::Selenium
  Driver.register_specialization :ie, Driver::InternetExplorerDriver
  Driver.register_specialization :internet_explorer, Driver::InternetExplorerDriver
end
