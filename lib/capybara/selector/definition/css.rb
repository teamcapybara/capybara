# frozen_string_literal: true

Capybara.add_selector(:css, locator_type: [String, Symbol], raw_locator: true) do
  css do |css|
    if css.is_a? Symbol
      warn "DEPRECATED: Passing a symbol (#{css.inspect}) as the CSS locator is deprecated - please pass a string instead."
    end
    css
  end
end
