# frozen_string_literal: true

class Capybara::Selenium::ChromeNode < Capybara::Selenium::Node
  def set_file(value) # rubocop:disable Naming/AccessorMethodName
    super(value)
  rescue ::Selenium::WebDriver::Error::ExpectedError => e
    if e.message =~ /File not found : .+\n.+/m
      raise ArgumentError, "Selenium < 3.14 with remote Chrome doesn't support multiple file upload"
    end
    raise
  end

  def drag_to(element)
    return super unless self[:draggable] == 'true'

    scroll_if_needed { driver.browser.action.click_and_hold(native).perform }
    driver.execute_script HTML5_DRAG_DROP_SCRIPT, self, element
  end

private

  def bridge
    driver.browser.send(:bridge)
  end

  HTML5_DRAG_DROP_SCRIPT = <<~JS
    var source = arguments[0];
    var target = arguments[1];

    var dt = new DataTransfer();
    var opts = { cancelable: true, bubbles: true, dataTransfer: dt };

    var dragEvent = new DragEvent('dragstart', opts);
    source.dispatchEvent(dragEvent);
    target.scrollIntoView({behavior: 'instant', block: 'center', inline: 'center'});
    var dragOverEvent = new DragEvent('dragover', opts);
    target.dispatchEvent(dragOverEvent);
    var dragLeaveEvent = new DragEvent('dragleave', opts);
    target.dispatchEvent(dragLeaveEvent);
    if (dragOverEvent.defaultPrevented) {
      var dropEvent = new DragEvent('drop', opts);
      target.dispatchEvent(dropEvent);
    }
    var dragEndEvent = new DragEvent('dragend', opts);
    source.dispatchEvent(dragEndEvent);
  JS
end
