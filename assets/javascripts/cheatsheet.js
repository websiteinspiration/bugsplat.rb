$(function() {
  $(document).on('click', 'div.toggle-example code', function(event) {
      $(event.target).siblings('pre').toggle();
  });
});
