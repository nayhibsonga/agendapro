$(function() {
	$.validator.setDefaults({
		ignore: ""
	});

	$.validator.addMethod("alphaNumeric", function(value, element) {
		return this.optional(element) || /^\S*[a-z0-9_-]+\S*$/i.test(value) && !value.match(/[áäâàéëêèíïîìóöôòúüûùñ.]/gi); // letters, digits,_,-
	}, "No se pueden usar caractéres especiales");

	$.validator.addMethod('filesize', function(value, element, param) {
		// param = size (en bytes) 
		// element = element to validate (<input>)
		// value = value of the element (file name)
		return this.optional(element) || (element.files[0].size <= param) 
	});
});