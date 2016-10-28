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
    $('body').append($('<p class="change_event_triggered"></p>').text(this.value));
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
    }, 550)
  });
  $('#change-title').click(function() {
    setTimeout(function() {
      $('title').text('changed title')
    }, 250)
  });
  $('#click-test').on({
    dblclick: function() {
      $(this).after('<a id="has-been-double-clicked" href="#">Has been double clicked</a>');
    },
    contextmenu: function(e) {
      e.preventDefault();
      $(this).after('<a id="has-been-right-clicked" href="#">Has been right clicked</a>');
    }
  });
  $('#open-alert').click(function() {
    alert('Alert opened [*Yay?*]');
    $(this).attr('opened', 'true');
  });
  $('#open-delayed-alert').click(function() {
    var link = this;
    setTimeout(function() {
      alert('Delayed alert opened');
      $(link).attr('opened', 'true');
    }, 250);
  });
  $('#open-slow-alert').click(function() {
    var link = this;
    setTimeout(function() {
      alert('Delayed alert opened');
      $(link).attr('opened', 'true');
    }, 3000);
  });
  $('#open-confirm').click(function() {
    if(confirm('Confirm opened')) {
      $(this).attr('confirmed', 'true');
    } else {
      $(this).attr('confirmed', 'false');
    }
  });
  $('#open-prompt').click(function() {
    var response = prompt('Prompt opened');
    if(response === null) {
      $(this).attr('response', 'dismissed');
    } else {
      $(this).attr('response', response);
    }
  });
  $('#open-twice').click(function() {
    if (confirm('Are you sure?')) {
      if (!confirm('Are you really sure?')) {
        $(this).attr('confirmed', 'false');
      }
    }
  })
  $('#delayed-page-change').click(function() {
    setTimeout(function() {
      window.location.pathname = '/with_html'
    }, 500)
  })
  $('#with-key-events').keydown(function(e){
    $('#key-events-output').append('keydown:'+e.which+' ')
  });
  $('#disable-on-click').click(function(e){
    var input = this
    setTimeout(function() {
      input.disabled = true;
    }, 500)
  })
  $('#set-storage').click(function(e){
    sessionStorage.setItem('session', 'session_value');
    localStorage.setItem('local', 'local value');
  })
});
