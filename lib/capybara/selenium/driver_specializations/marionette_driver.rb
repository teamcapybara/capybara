# frozen_string_literal: true

require 'capybara/selenium/nodes/marionette_node'

module Capybara::Selenium::Driver::MarionetteDriver
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

private

  def build_node(native_node)
    ::Capybara::Selenium::MarionetteNode.new(self, native_node)
  end
end
