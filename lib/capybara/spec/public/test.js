var activeRequests = 0;
$(function() {
  $('#change').text('I changed it');
  $('#drag').draggable();
  $('#drop').droppable({
    drop: function(event, ui) {
      ui.draggable.remove();
      $(this).html('Dropped!');
    }
  });
  $('#clickable').click(function() {
    var link = $(this);
    setTimeout(function() {
      $(link).after('<a id="has-been-clicked" href="#">Has been clicked</a>');
      $(link).after('<input type="submit" value="New Here">');
      $(link).after('<input type="text" id="new_field">');
      $('#change').remove();
    }, 500);
    return false;
  });
  $('#waiter').change(function() {
    activeRequests = 1;
    setTimeout(function() {
      activeRequests = 0;
    }, 500);
  });
  $('#with_focus_event').focus(function() {
    $('body').append('<p id="focus_event_triggered">Focus Event triggered</p>');
  });
  $('#checkbox_with_event').click(function() {
    $('body').append('<p id="checkbox_event_triggered">Checkbox event triggered</p>');
  });
  $('#fire_ajax_request').click(function() {
    $.ajax({url: "/slow_response", context: document.body, success: function() {
      $('body').append('<p id="ajax_request_done">Ajax request done</p>');
    }});
  });
  $('#reload-link').click(function() {
    setTimeout(function() {
      $('#reload-me').replaceWith('<div id="reload-me"><em><a>RELOADED</a></em></div>');
    }, 250)
  });
});
