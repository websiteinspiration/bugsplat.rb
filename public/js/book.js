$(".payment-button").click(function(event) {
  var permalink = $(this).data()["permalink"];
  if (typeof(permalink) === "undefined") {
      return true;
  }
  var frameSrc = "https://sales.bugsplat.info/iframe/" + permalink;
  $.colorbox({href: frameSrc, iframe: true, width: '800px', height: '400px'});
  return false;
});

