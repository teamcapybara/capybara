# frozen_string_literal: true

# require 'capybara/selenium/extensions/html5_drag'

class Capybara::Selenium::SafariNode < Capybara::Selenium::Node
  # include Html5Drag

  def click(keys = [], **options)
    # driver.execute_script('arguments[0].scrollIntoViewIfNeeded({block: "center"})', self)
    super
  rescue ::Selenium::WebDriver::Error::ElementNotInteractableError
    if tag_name == 'tr'
      warn 'You are attempting to click a table row which has issues in safaridriver - '\
           'Your test should probably be clicking on a table cell like a user would. '\
           'Clicking the first cell in the row instead.'
      return find_css('th:first-child,td:first-child')[0].click(keys, options)
    end
    raise
  end

  def select_option
    driver.execute_script("arguments[0].closest('select').scrollIntoView()", self)
    super
  end

  def unselect_option
    driver.execute_script("arguments[0].closest('select').scrollIntoView()", self)
    super
  end

  def visible_text
    return '' unless visible?

    vis_text = driver.execute_script('return arguments[0].innerText', self)
    vis_text.gsub(/\ +/, ' ')
            .gsub(/[\ \n]*\n[\ \n]*/, "\n")
            .gsub(/\A[[:space:]&&[^\u00a0]]+/, '')
            .gsub(/[[:space:]&&[^\u00a0]]+\z/, '')
            .tr("\u00a0", ' ')
  end

  def disabled?
    return true if super

    # workaround for safaridriver reporting elements as enabled when they are nested in disabling elements
    if %w[option optgroup].include? tag_name
      return true if self[:disabled] == 'true'

      find_xpath('parent::*[self::optgroup or self::select]')[0].disabled?
    else
      !find_xpath(DISABLED_BY_FIELDSET_XPATH).empty?
    end
  end

  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    # By default files are appended so we have to clear here if its multiple and already set
    native.clear if multiple? && driver.evaluate_script('arguments[0].files', self).any?
    super
  end

  def send_keys(*args)
    return super(*args.map { |arg| arg == :space ? ' ' : arg }) if args.none? { |arg| arg.is_a? Array }

    native.click
    _send_keys(args).perform
  end

  def set_text(value, clear: nil, **_unused)
    value = value.to_s
    if clear == :backspace
      # Clear field by sending the correct number of backspace keys.
      backspaces = [:backspace] * self.value.to_s.length
      send_keys(*([[:control, 'e']] + backspaces + [value]))
    else
      super.tap do
        # React doesn't see the safaridriver element clear
        send_keys(:space, :backspace) if value.to_s.empty? && clear.nil?
      end
    end
  end

private

  def bridge
    driver.browser.send(:bridge)
  end

  DISABLED_BY_FIELDSET_XPATH = XPath.generate do |x|
    x.parent(:fieldset)[
      x.attr(:disabled)
    ] + x.ancestor[
      ~x.self(:legend) |
      x.preceding_sibling(:legend)
    ][
      x.parent(:fieldset)[
        x.attr(:disabled)
      ]
    ]
  end.to_s.freeze

  def _send_keys(keys, actions = browser_action, down_keys = ModifierKeysStack.new)
    case keys
    when :control, :left_control, :right_control,
         :alt, :left_alt, :right_alt,
         :shift, :left_shift, :right_shift,
         :meta, :left_meta, :right_meta,
         :command
      down_keys.press(keys)
      actions.key_down(keys)
    when String
      keys = keys.upcase if down_keys&.include?(:shift)
      actions.send_keys(keys)
    when Symbol
      actions.send_keys(keys)
    when Array
      down_keys.push
      keys.each { |sub_keys| _send_keys(sub_keys, actions, down_keys) }
      down_keys.pop.reverse_each { |key| actions.key_up(key) }
    else
      raise ArgumentError, 'Unknown keys type'
    end
    actions
  end

  class ModifierKeysStack
    def initialize
      @stack = []
    end

    def include?(key)
      @stack.flatten.include?(key)
    end

    def press(key)
      @stack.last.push(key)
    end

    def push
      @stack.push []
    end

    def pop
      @stack.pop
    end
  end
  private_constant :ModifierKeysStack
end
