//====== Map ======//

function initializeMap(lat, lng, mapDiv) {
    var properties = {
        center: new google.maps.LatLng(lat, lng),
        zoom:   15,
        panControl: false,
        zoomControl: true,
        zoomControlOptions: {
            style: google.maps.ZoomControlStyle.SMALL
        },
        mapTypeControl: true,
        mapTypeControlOptions: {
            style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
        },
        scaleControl: false,
        streetViewControl: false,
        overviewMapControl: false,
        mapTypeId:  google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById(mapDiv), properties);
}

function setMarker(latlng, local, n) {
    var marker;
    marker = new google.maps.Marker({
        position: latlng,
        map: map,
        icon: new google.maps.MarkerImage(
            "http://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld="+ n + "|da4f49|FFFFFF",
            null, null, new google.maps.Point(0, 42))
    });
    marker.setMap(map);
    
    var infowindow = new google.maps.InfoWindow({
        content: local
    });
    google.maps.event.addListener(marker, 'click', function() {
        infowindow.open(map,marker);
    });
}

function centerMap(geolocation, fullBounds) {
	var geocoder = new google.maps.Geocoder();
	geocoder.geocode( { 'address' : geolocation }, function (results, status) {
		if (status == google.maps.GeocoderStatus.OK) {
			map.setCenter(results[0].geometry.location);
		}
	});

    map.fitBounds(fullBounds);
}

$(function() {
	var map;
	initializeMap(-33.413084, -70.592161, 'map');
	
    var fullBounds = new google.maps.LatLngBounds();

	var i = 1;
	$.each($('#results').data('results'), function (key, local) {
		loadSchedule(local.id);
		var latLng = new google.maps.LatLng(local.latitude, local.longitude);
		setMarker(latLng, local.name, i);
		i++;

        fullBounds.extend(latLng);
	});
	
	var geolocation = $('#geolocation').data('geolocation');
	centerMap(geolocation, fullBounds);
});