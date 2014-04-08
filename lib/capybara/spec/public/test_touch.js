$(function() {
  $('#touchable').on({
    longTap: function() {
        $(this).text('Long pressed');
        $(this).after('<div>Long pressed</div>');
        return false;
      },
    swipe: function() {
        $(this).text('Flicked');
        return false;
      },
    singleTap: function() {
        $(this).text('Tapped');
        return false;
      },
    doubleTap: function() {
        $(this).text('Double tapped');
        return false;
      }
    });
  $('#swipeable').on({
    swipeDown: function() {
        $(this).text('Swiped down');
        return false;
      },
    swipeRight: function() {
        $(this).text('Swiped right');
        return false;
      }
    });
});
