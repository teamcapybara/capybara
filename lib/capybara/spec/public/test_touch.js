$(function() {
  $('#touchable').on('longTap', function() {
    $(this).text('Long pressed');
    $(this).after('<div>Long pressed</div>');
    return false;
  });
  $('#touchable').on('swipe', function() {
    $(this).text('Flicked');
    return false;
  });
  $('#touchable').on('singleTap', function() {
    $(this).text('Tapped');
    return false;
  });
  $('#touchable').on('doubleTap', function() {
    $(this).text('Double tapped');
    return false;
  });
});
