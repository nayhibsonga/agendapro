function geocode(geolocation) {
  var geocoder = new google.maps.Geocoder();
  geocoder.geocode( { 'address' : geolocation }, function (results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      $('#location_latitude').val(results[0].geometry.location.lat());
      $('#location_longitude').val(results[0].geometry.location.lng());
    }
  });
}

$(function () {
  $('#location_address').change(function () {
    var address = this.value;
    var district = $('#location_district_id').val();
    if (district != '') {
      $.getJSON('/get_direction', {id: district}, function (direction) {
        var geolocation = address + ', ' + direction;
        geocode(geolocation);
      });
    }
  });

  $('#location_district_id').change(function () {
    var address = $('#location_address').val();
    var district = this.value;
    if (district != '') {
      $.getJSON('/get_direction', {id: district}, function (direction) {
        var geolocation = address + ', ' + direction;
        geocode(geolocation);
      });
    }
  });
});