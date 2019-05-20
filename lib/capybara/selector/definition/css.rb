# frozen_string_literal: true

Capybara.add_selector(:css, locator_type: [String, Symbol], raw_locator: true) do
  css do |css|
    warn "DEPRECATED: Passing a symbol (#{css.inspect}) as the CSS locator is deprecated - please pass a string instead." if css.is_a? Symbol
    css
  end
end
