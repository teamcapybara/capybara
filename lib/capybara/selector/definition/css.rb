# frozen_string_literal: true

Capybara.add_selector(:css, locator_type: [String, Symbol], raw_locator: true) do
  css { |css| css }
end
