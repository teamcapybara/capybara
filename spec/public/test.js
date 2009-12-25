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
      $(link).after('<a href="#">Has been clicked</a>');
      $(link).after('<input type="submit" value="New Here">');
      $(link).after('<input type="text" id="new_field">');
    }, 500);
    return false;
  });
  $('#waiter').change(function() {
    activeRequests = 1;
    setTimeout(function() {
      activeRequests = 0;
    }, 500);
  });
});