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
  $('#slow-click').click(function() {
    var link = $(this);
    setTimeout(function() {
      $(link).after('<a id="slow-clicked" href="#">Slow link clicked</a>');
    }, 4000);
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
  $('#with_change_event').change(function() {
    if($(this).val() == '') $(this).val("Can't be empty");
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
      $('#reload-me').replaceWith('<div id="reload-me"><em><a>has been reloaded</a></em></div>');
    }, 250)
  });
  $('#reload-list').click(function() {
    setTimeout(function() {
      $('#the-list').html('<li>Foo</li><li>Bar</li>');
    }, 250)
  });
  $('#change-title').click(function() {
    setTimeout(function() {
      $('title').text('changed title')
    }, 250)
  });
});
