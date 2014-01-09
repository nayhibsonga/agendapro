$(function() {
  var map;
  initializeMap(-33.413084, -70.592161, 'map');

  var i = 1;
  $.each($('#results').data('results'), function (key, local) {
    loadSchedule(local.id);
    var latLng = new google.maps.LatLng(local.latitude, local.longitude);
    setMarker(latLng, local.name, i);
    i++;
  });
});