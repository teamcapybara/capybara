Capybara.add_selector(:xpath) do
  xpath { |xpath| xpath }
end

Capybara.add_selector(:css) do
  css { |css| css }
end

Capybara.add_selector(:id) do
  xpath { |id| XPath.descendant[XPath.attr(:id) == id.to_s] }
end

Capybara.add_selector(:field) do
  xpath { |locator| XPath::HTML.field(locator) }
end

Capybara.add_selector(:fieldset) do
  xpath { |locator| XPath::HTML.fieldset(locator) }
end

Capybara.add_selector(:link_or_button) do
  xpath { |locator| XPath::HTML.link_or_button(locator) }
end

Capybara.add_selector(:link) do
  xpath { |locator| XPath::HTML.link(locator) }
end

Capybara.add_selector(:button) do
  xpath { |locator| XPath::HTML.button(locator) }
end

Capybara.add_selector(:fillable_field) do
  xpath { |locator| XPath::HTML.fillable_field(locator) }
end

Capybara.add_selector(:radio_button) do
  xpath { |locator| XPath::HTML.radio_button(locator) }
end

Capybara.add_selector(:checkbox) do
  xpath { |locator| XPath::HTML.checkbox(locator) }
end

Capybara.add_selector(:select) do
  xpath { |locator| XPath::HTML.select(locator) }
end

Capybara.add_selector(:option) do
  xpath { |locator| XPath::HTML.option(locator) }
end

Capybara.add_selector(:file_field) do
  xpath { |locator| XPath::HTML.file_field(locator) }
end

Capybara.add_selector(:table) do
  xpath { |locator| XPath::HTML.table(locator) }
end
