# frozen_string_literal: true

require 'capybara/selenium/nodes/safari_node'

module Capybara::Selenium::Driver::SafariDriver
private # rubocop:disable Layout/IndentationWidth

  def build_node(native_node, initial_cache = {})
    ::Capybara::Selenium::SafariNode.new(self, native_node, initial_cache)
  end

  def bridge
    browser.send(:bridge)
  end
end
