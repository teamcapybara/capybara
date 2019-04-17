# frozen_string_literal: true

module Capybara::Selenium::Driver::InternetExplorerDriver
  def switch_to_frame(frame)
    return super unless frame == :parent

    # iedriverserver has an issue if the current frame is removed from within it
    # so we have to move to the default_content and iterate back through the frames
    handles = @frame_handles[current_window_handle]
    browser.switch_to.default_content
    handles.tap(&:pop).each { |fh| browser.switch_to.frame(fh) }
  end
end

module Capybara::Selenium
  Driver.register_specialization :ie, Driver::InternetExplorerDriver
  Driver.register_specialization :internet_explorer, Driver::InternetExplorerDriver
end
