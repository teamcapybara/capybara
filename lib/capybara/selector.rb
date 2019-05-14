# frozen_string_literal: true

require 'capybara/selector/xpath_extensions'
require 'capybara/selector/selector'
require 'capybara/selector/definition'

# rubocop:disable Style/AsciiComments
#
# ## Built-in Selectors
#
#   * **:xpath** - Select elements by XPath expression
#     * Locator: An XPath expression
#
#   * **:css** - Select elements by CSS selector
#     * Locator: A CSS selector
#
#   * **:id** - Select element by id
#     * Locator: (String, Regexp, XPath::Expression) The id of the element to match
#
#   * **:field** - Select field elements (input [not of type submit, image, or hidden], textarea, select)
#     * Locator: Matches against the id, Capybara.test_id attribute, name, or placeholder
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Matches the id attribute
#       * :name (String) — Matches the name attribute
#       * :placeholder (String) — Matches the placeholder attribute
#       * :type (String) — Matches the type attribute of the field or element type for 'textarea' and 'select'
#       * :readonly (Boolean)
#       * :with (String) — Matches the current value of the field
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :checked (Boolean) — Match checked fields?
#       * :unchecked (Boolean) — Match unchecked fields?
#       * :disabled (Boolean) — Match disabled field?
#       * :multiple (Boolean) — Match fields that accept multiple values
#       * :style (String, Regexp, Hash)
#
#   * **:fieldset** - Select fieldset elements
#     * Locator: Matches id or contents of wrapped legend
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Matches id attribute
#       * :legend (String) — Matches contents of wrapped legend
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :style (String, Regexp, Hash)
#
#   * **:link** - Find links ( <a> elements with an href attribute )
#     * Locator: Matches the id or title attributes, or the string content of the link, or the alt attribute of a contained img element
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Matches the id attribute
#       * :title (String) — Matches the title attribute
#       * :alt (String) — Matches the alt attribute of a contained img element
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :href (String, Regexp, nil, false) — Matches the normalized href of the link, if nil will find <a> elements with no href attribute, if false ignores href
#       * :style (String, Regexp, Hash)
#
#   * **:button** - Find buttons ( input [of type submit, reset, image, button] or button elements )
#     * Locator: Matches the id, Capybara.test_id attribute, name, value, or title attributes, string content of a button, or the alt attribute of an image type button or of a descendant image of a button
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Matches the id attribute
#       * :name (String) - Matches the name attribute
#       * :title (String) — Matches the title attribute
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :value (String) — Matches the value of an input button
#       * :type
#       * :style (String, Regexp, Hash)
#
#   * **:link_or_button** - Find links or buttons
#     * Locator: See :link and :button selectors
#
#   * **:fillable_field** - Find text fillable fields ( textarea, input [not of type submit, image, radio, checkbox, hidden, file] )
#     * Locator: Matches against the id, Capybara.test_id attribute, name, or placeholder
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Matches the id attribute
#       * :name (String) — Matches the name attribute
#       * :placeholder (String) — Matches the placeholder attribute
#       * :with (String) — Matches the current value of the field
#       * :type (String) — Matches the type attribute of the field or element type for 'textarea'
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :disabled (Boolean) — Match disabled field?
#       * :multiple (Boolean) — Match fields that accept multiple values
#       * :style (String, Regexp, Hash)
#
#   * **:radio_button** - Find radio buttons
#     * Locator: Match id, Capybara.test_id attribute, name, or associated label text
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Matches the id attribute
#       * :name (String) — Matches the name attribute
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :checked (Boolean) — Match checked fields?
#       * :unchecked (Boolean) — Match unchecked fields?
#       * :disabled (Boolean) — Match disabled field?
#       * :option (String) — Match the value
#       * :style (String, Regexp, Hash)
#
#   * **:checkbox** - Find checkboxes
#     * Locator: Match id, Capybara.test_id attribute, name, or associated label text
#     * Filters:
#       * *:id (String, Regexp, XPath::Expression) — Matches the id attribute
#       * *:name (String) — Matches the name attribute
#       * *:class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * *:checked (Boolean) — Match checked fields?
#       * *:unchecked (Boolean) — Match unchecked fields?
#       * *:disabled (Boolean) — Match disabled field?
#       * *:option (String) — Match the value
#       * :style (String, Regexp, Hash)
#
#   * **:select** - Find select elements
#     * Locator: Match id, Capybara.test_id attribute, name, placeholder, or associated label text
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Matches the id attribute
#       * :name (String) — Matches the name attribute
#       * :placeholder (String) — Matches the placeholder attribute
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :disabled (Boolean) — Match disabled field?
#       * :multiple (Boolean) — Match fields that accept multiple values
#       * :options (Array<String>) — Exact match options
#       * :with_options (Array<String>) — Partial match options
#       * :selected (String, Array<String>) — Match the selection(s)
#       * :with_selected (String, Array<String>) — Partial match the selection(s)
#       * :style (String, Regexp, Hash)
#
#   * **:option** - Find option elements
#     * Locator: Match text of option
#     * Filters:
#       * :disabled (Boolean) — Match disabled option
#       * :selected (Boolean) — Match selected option
#
#   * **:datalist_input**
#     * Locator:
#     * Filters:
#       * :disabled
#       * :name
#       * :placeholder
#
#   * **:datalist_option**
#     * Locator:
#
#   * **:file_field** - Find file input elements
#     * Locator: Match id, Capybara.test_id attribute, name, or associated label text
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Matches the id attribute
#       * :name (String) — Matches the name attribute
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :disabled (Boolean) — Match disabled field?
#       * :multiple (Boolean) — Match field that accepts multiple values
#       * :style (String, Regexp, Hash)
#
#   * **:label** - Find label elements
#     * Locator: Match id or text contents
#     * Filters:
#       * :for (Element, String, Regexp) — The element or id of the element associated with the label
#
#   * **:table** - Find table elements
#     * Locator: id or caption text of table
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Match id attribute of table
#       * :caption (String) — Match text of associated caption
#       * :class ((String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :style (String, Regexp, Hash)
#       * :with_rows (Array<Array<String>>, Array<Hash<String, String>>) - Partial match <td> data - visibility of <td> elements is not considered
#       * :rows (Array<Array<String>>) — Match all <td>s - visibility of <td> elements is not considered
#       * :with_cols (Array<Array<String>>, Array<Hash<String, String>>) - Partial match <td> data - visibility of <td> elements is not considered
#       * :cols (Array<Array<String>>) — Match all <td>s - visibility of <td> elements is not considered
#
#   * **:table_row** - Find table row
#     * Locator: Array<String>, Hash<String,String> table row <td> contents - visibility of <td> elements is not considered
#
#   * **:frame** - Find frame/iframe elements
#     * Locator: Match id or name
#     * Filters:
#       * :id (String, Regexp, XPath::Expression) — Match id attribute
#       * :name (String) — Match name attribute
#       * :class (String, Array<String>, Regexp, XPath::Expression) — Matches the class(es) provided
#       * :style (String, Regexp, Hash)
#
#   * **:element**
#     * Locator: Type of element ('div', 'a', etc) - if not specified defaults to '*'
#     * Filters: Matches on any element attribute
class Capybara::Selector; end
#
# rubocop:enable Style/AsciiComments

Capybara::Selector::FilterSet.add(:_field) do
  node_filter(:checked, :boolean) { |node, value| !(value ^ node.checked?) }
  node_filter(:unchecked, :boolean) { |node, value| (value ^ node.checked?) }
  node_filter(:disabled, :boolean, default: false, skip_if: :all) { |node, value| !(value ^ node.disabled?) }

  expression_filter(:name) { |xpath, val| xpath[XPath.attr(:name) == val] }
  expression_filter(:placeholder) { |xpath, val| xpath[XPath.attr(:placeholder) == val] }
  expression_filter(:disabled) { |xpath, val| val ? xpath : xpath[~XPath.attr(:disabled)] }
  expression_filter(:multiple) { |xpath, val| xpath[val ? XPath.attr(:multiple) : ~XPath.attr(:multiple)] }

  describe(:expression_filters) do |name: nil, placeholder: nil, disabled: nil, multiple: nil, **|
    desc = +''
    desc << ' that is not disabled' if disabled == false
    desc << " with name #{name}" if name
    desc << " with placeholder #{placeholder}" if placeholder
    desc << ' with the multiple attribute' if multiple == true
    desc << ' without the multiple attribute' if multiple == false
    desc
  end

  describe(:node_filters) do |checked: nil, unchecked: nil, disabled: nil, **|
    desc, states = +'', []
    states << 'checked' if checked || (unchecked == false)
    states << 'not checked' if unchecked || (checked == false)
    states << 'disabled' if disabled == true
    desc << " that is #{states.join(' and ')}" unless states.empty?
    desc
  end
end

require 'capybara/selector/definition/xpath'
require 'capybara/selector/definition/css'
require 'capybara/selector/definition/id'
require 'capybara/selector/definition/field'
require 'capybara/selector/definition/fieldset'
require 'capybara/selector/definition/link'
require 'capybara/selector/definition/button'
require 'capybara/selector/definition/link_or_button'
require 'capybara/selector/definition/fillable_field'
require 'capybara/selector/definition/radio_button'
require 'capybara/selector/definition/checkbox'
require 'capybara/selector/definition/select'
require 'capybara/selector/definition/datalist_input'
require 'capybara/selector/definition/option'
require 'capybara/selector/definition/datalist_option'
require 'capybara/selector/definition/file_field'
require 'capybara/selector/definition/label'
require 'capybara/selector/definition/table'
require 'capybara/selector/definition/table_row'
require 'capybara/selector/definition/frame'
require 'capybara/selector/definition/element'
