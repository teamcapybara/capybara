# frozen_string_literal: true

class Capybara::Selenium::Node
  module Html5Drag
  private

    def html5_drag_to(element)
      driver.execute_script MOUSEDOWN_TRACKER
      scroll_if_needed { browser_action.click_and_hold(native).perform }
      if driver.evaluate_script('window.capybara_mousedown_prevented')
        element.scroll_if_needed { browser_action.move_to(element.native).release.perform }
      else
        driver.execute_script HTML5_DRAG_DROP_SCRIPT, self, element
        browser_action.release.perform
      end
    end

    def html5_draggable?
      # Workaround https://github.com/SeleniumHQ/selenium/issues/6396
      native.property('draggable')
    end

    MOUSEDOWN_TRACKER = <<~JS
      document.addEventListener('mousedown', ev => {
        window.capybara_mousedown_prevented = ev.defaultPrevented;
      }, { once: true, passive: true })
    JS

    HTML5_DRAG_DROP_SCRIPT = <<~JS
      var source = arguments[0];
      var target = arguments[1];

      var dt = new DataTransfer();
      var opts = { cancelable: true, bubbles: true, dataTransfer: dt };

      if (source.tagName == 'A'){
        dt.setData('text/uri-list', source.href);
        dt.setData('text', source.href);
      }
      if (source.tagName == 'IMG'){
        dt.setData('text/uri-list', source.src);
        dt.setData('text', source.src);
      }
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
end
