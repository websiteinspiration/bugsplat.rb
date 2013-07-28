$(".payment-button").click(function(event) {
  var permalink = $(this).data()["permalink"];
  if (typeof(permalink) === "undefined") {
      return true;
  }
  var frameSrc = "https://sales.petekeen.net/iframe/" + permalink;
  $.colorbox({href: frameSrc, iframe: true, width: '800px', height: '400px'});
  return false;
});

