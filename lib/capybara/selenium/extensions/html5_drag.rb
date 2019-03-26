# frozen_string_literal: true

class Capybara::Selenium::Node
  module Html5Drag
  # Implement methods to emulate HTML5 drag and drop

  private # rubocop:disable Layout/IndentationWidth

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

      function rectCenter(rect){
        return new DOMPoint(
          (rect.left + rect.right)/2,
          (rect.top + rect.bottom)/2
        );
      }

      function pointOnRect(pt, rect) {
      	var rectPt = rectCenter(rect);
      	var slope = (rectPt.y - pt.y) / (rectPt.x - pt.x);

      	if (pt.x <= rectPt.x) { // left side
      		var minXy = slope * (rect.left - pt.x) + pt.y;
      		if (rect.top <= minXy && minXy <= rect.bottom)
            return new DOMPoint(rect.left, minXy);
      	}

      	if (pt.x >= rectPt.x) { // right side
      		var maxXy = slope * (rect.right - pt.x) + pt.y;
      		if (rect.top <= maxXy && maxXy <= rect.bottom)
            return new DOMPoint(rect.right, maxXy);
      	}

      	if (pt.y <= rectPt.y) { // top side
      		var minYx = (rectPt.top - pt.y) / slope + pt.x;
      		if (rect.left <= minYx && minYx <= rect.right)
            return new DOMPoint(minYx, rect.top);
      	}

      	if (pt.y >= rectPt.y) { // bottom side
      		var maxYx = (rect.bottom - pt.y) / slope + pt.x;
      		if (rect.left <= maxYx && maxYx <= rect.right)
            return new DOMPoint(maxYx, rect.bottom);
      	}

        return new DOMPoint(pt.x,pt.y);
      }

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
      var targetRect = target.getBoundingClientRect();
      var sourceCenter = rectCenter(source.getBoundingClientRect());

      // fire 2 dragover events to simulate dragging with a direction
      var entryPoint = pointOnRect(sourceCenter, targetRect)
      var dragOverOpts = Object.assign({clientX: entryPoint.x, clientY: entryPoint.y}, opts);
      var dragOverEvent = new DragEvent('dragover', dragOverOpts);
      target.dispatchEvent(dragOverEvent);

      var targetCenter = rectCenter(targetRect);
      dragOverOpts = Object.assign({clientX: targetCenter.x, clientY: targetCenter.y}, opts);
      dragOverEvent = new DragEvent('dragover', dragOverOpts);
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
