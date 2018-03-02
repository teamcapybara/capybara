# frozen_string_literal: true

module Capybara
  module Plugins
    class Select2
      def select(scope, value, from: nil, **options)
        select2 = if from
          scope.find(:select2, from, options.merge(visible: false))
        else
          select = scope.find(:option, value, options).ancestor(:css, 'select', visible: false)
          select.find(:xpath, XPath.next_sibling(:span)[XPath.attr(:class).contains_word('select2')][XPath.attr(:class).contains_word('select2-container')])
        end
        select2.click
        scope.find(:select2_option, value).click
      end
    end
  end
end

Capybara.add_selector(:select2) do
  xpath do |locator, **options|
    xpath = XPath.descendant(:select)
    xpath = locate_field(xpath, locator, options)
    xpath = xpath.next_sibling(:span)[XPath.attr(:class).contains_word('select2')][XPath.attr(:class).contains_word('select2-container')]
    xpath
  end
end

Capybara.add_selector(:select2_option) do
  xpath do |locator|
    xpath = XPath.anywhere(:ul)[XPath.attr(:class).contains_word('select2-results__options')][XPath.attr(:id)]
    xpath = xpath.descendant(:li)[XPath.attr(:role) == 'treeitem']
    xpath = xpath[XPath.string.n.is(locator.to_s)] unless locator.nil?
    xpath
  end
end

Capybara.register_plugin(:select2, Capybara::Plugins::Select2.new)
