# frozen_string_literal: true

class Capybara::Selenium::Node
  module Html5Drag
    # Implement methods to emulate HTML5 drag and drop

    def drag_to(element, delay: 0.05)
      driver.execute_script MOUSEDOWN_TRACKER
      scroll_if_needed { browser_action.click_and_hold(native).perform }
      if driver.evaluate_script('window.capybara_mousedown_prevented || !arguments[0].draggable', self)
        element.scroll_if_needed { browser_action.move_to(element.native).release.perform }
      else
        driver.evaluate_async_script HTML5_DRAG_DROP_SCRIPT, self, element, delay * 1000
        browser_action.release.perform
      end
    end

  private

    def html5_drop(*args)
      if args[0].is_a? String
        input = driver.evaluate_script ATTACH_FILE
        input.set_file(args)
        driver.execute_script DROP_FILE, self, input
      else
        items = args.each_with_object([]) do |arg, arr|
          arg.each_with_object(arr) do |(type, data), arr_|
            arr_ << { type: type, data: data }
          end
        end
        driver.execute_script DROP_STRING, items, self
      end
    end

    DROP_STRING = <<~JS
      var strings = arguments[0],
          el = arguments[1],
          dt = new DataTransfer(),
          opts = { cancelable: true, bubbles: true, dataTransfer: dt };
      for (var i=0; i < strings.length; i++){
        if (dt.items) {
          dt.items.add(strings[i]['data'], strings[i]['type']);
        } else {
          dt.setData(strings[i]['type'], strings[i]['data']);
        }
      }
      var dropEvent = new DragEvent('drop', opts);
      el.dispatchEvent(dropEvent);
    JS

    DROP_FILE = <<~JS
      var el = arguments[0],
          input = arguments[1],
          files = input.files,
          dt = new DataTransfer(),
          opts = { cancelable: true, bubbles: true, dataTransfer: dt };
      input.parentElement.removeChild(input);
      if (dt.items){
        for (var i=0; i<files.length; i++){
          dt.items.add(files[i]);
        }
      } else {
        Object.defineProperty(dt, "files", {
          value: files,
          writable: false
        });
      }
      var dropEvent = new DragEvent('drop', opts);
      el.dispatchEvent(dropEvent);
    JS

    ATTACH_FILE = <<~JS
      (function(){
        var input = document.createElement('INPUT');
        input.type = "file";
        input.id = "_capybara_drop_file";
        input.multiple = true;
        document.body.appendChild(input);
        return input;
      })()
    JS

    MOUSEDOWN_TRACKER = <<~JS
      document.addEventListener('mousedown', ev => {
        window.capybara_mousedown_prevented = ev.defaultPrevented;
      }, { once: true, passive: true })
    JS

    HTML5_DRAG_DROP_SCRIPT = <<~JS
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

      function dragEnterTarget() {
        target.scrollIntoView({behavior: 'instant', block: 'center', inline: 'center'});
        var targetRect = target.getBoundingClientRect();
        var sourceCenter = rectCenter(source.getBoundingClientRect());

        // fire 2 dragover events to simulate dragging with a direction
        var entryPoint = pointOnRect(sourceCenter, targetRect)
        var dragOverOpts = Object.assign({clientX: entryPoint.x, clientY: entryPoint.y}, opts);
        var dragOverEvent = new DragEvent('dragover', dragOverOpts);
        target.dispatchEvent(dragOverEvent);
        window.setTimeout(dragOnTarget, step_delay);
      }

      function dragOnTarget() {
        var targetCenter = rectCenter(target.getBoundingClientRect());
        var dragOverOpts = Object.assign({clientX: targetCenter.x, clientY: targetCenter.y}, opts);
        var dragOverEvent = new DragEvent('dragover', dragOverOpts);
        target.dispatchEvent(dragOverEvent);
        window.setTimeout(dragLeave, step_delay, dragOverEvent.defaultPrevented);
      }

      function dragLeave(drop) {
        var dragLeaveEvent = new DragEvent('dragleave', opts);
        target.dispatchEvent(dragLeaveEvent);
        if (drop) {
          var dropEvent = new DragEvent('drop', opts);
          target.dispatchEvent(dropEvent);
        }
        var dragEndEvent = new DragEvent('dragend', opts);
        source.dispatchEvent(dragEndEvent);
        callback.call(true);
      }

      var source = arguments[0],
          target = arguments[1],
          step_delay = arguments[2],
          callback = arguments[3];

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

      window.setTimeout(dragEnterTarget, step_delay);
    JS
  end
end
