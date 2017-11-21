# @api private
class Capybara::Selector::ExpressionContext
  extend Forwardable
  include XPath

  def initialize(selector)
    @selector = selector
  end

  def_delegators :@selector, :custom_filters, :node_filters, :expression_filters

private

  def locate_field(xpath, locator, enable_aria_label: false, **_options)
    locate_xpath = xpath #need to save original xpath for the label wrap
    if locator
      locator = locator.to_s
      attr_matchers =  attr(:id).equals(locator) |
                       attr(:name).equals(locator) |
                       attr(:placeholder).equals(locator) |
                       attr(:id).equals(anywhere(:label)[string.n.is(locator)].attr(:for))
      attr_matchers = attr_matchers | attr(:'aria-label').is(locator) if enable_aria_label

      locate_xpath = locate_xpath[attr_matchers]
      locate_xpath = locate_xpath.union(descendant(:label)[string.n.is(locator)].descendant(xpath))
    end

    # locate_xpath = [:name, :placeholder].inject(locate_xpath) { |memo, ef| memo[find_by_attr(ef, options[ef])] }
    locate_xpath
  end

  def find_by_attr(attribute, value)
    finder_name = "find_by_#{attribute}_attr"
    if respond_to?(finder_name, true)
      send(finder_name, value)
    else
      value ? attr(attribute) == value : nil
    end
  end

  def find_by_class_attr(classes)
    if classes
      Array(classes).map do |klass|
        attr(:class).contains_word(klass)
      end.reduce(:&)
    else
      nil
    end
  end
end
