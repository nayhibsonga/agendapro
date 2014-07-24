/************************************************************************
*	Description: Takes a input that has a string representing a full	*
*	name, and split it into first name and last name. In case that the	*
*	name has more than 2 words it considered the 3th word as second		*
*	last name. If it has 4 words it is considered the first as first	*
*	name, the second as middle name, and 3th and 4th as last name. In	*
*	case of more than 4 words, the first two are first and middle name	*
*	and the rest are last name.											*
*	Parameter:															*
*		fullNameOrigin: selector where the value of the full name is.	*
*		firstNameTarget: selector where the value of the first name		*
*			should be.													*
*		lastNameTarget: selector where the value of the last name		*
*			should be.													*
*		form: (optional) selector of the form which the inputs belongs	*
************************************************************************/
function split_name (fullNameOrigin, firstNameTarget, lastNameTarget, form) {
	var fullNameObject, firstNameObject, lastNameObject;
	if (typeof form == "undefined" && form == null) {
		fullNameObject = $(fullNameOrigin);
		firstNameObject = $(firstNameTarget);
		lastNameObject = $(lastNameTarget);
	} else{
		var form = $(form);
		fullNameObject = form.find(fullNameOrigin);
		firstNameObject = form.find(firstNameTarget);
		lastNameObject = form.find(lastNameTarget);
	};
	fullNameObject.change(function (event) {
		var fullName = $(event.target).val();
		if (typeof fullName !== "undefined" && fullName != null) {
			if (typeof fullName == 'string') {
				var fullNameArray = fullName.split(' ');
				var fullNameArrayLength = fullNameArray.length;
				// Ensure that name has at least one character
				if (fullNameArrayLength > 0) {
					var firstName, lastName = '';
					// Split the name
					if (fullNameArrayLength < 2) {
						firstName = fullNameArray[0];
						lastName = fullNameArray[0];
					} else if (fullNameArrayLength == 2) {
						firstName = fullNameArray[0];
						lastName = fullNameArray[1];
					} else if (fullNameArrayLength == 3) {
						firstName = fullNameArray[0];
						lastName = fullNameArray[1] + ' ' + fullNameArray[2];
					} else {
						firstName = fullNameArray[0] + ' ' + fullNameArray[1];
						for (var i = 2; i < fullNameArray.length; i++) {
							lastName += ' ' + fullNameArray[i];
						};
						lastName = lastName.trim();
					};

					// Asing the firts and last name
					firstNameObject.val(firstName);
					lastNameObject.val(lastName);
				} else{
					window.console.warn('Origin must be not empty');
				};
			} else{
				window.console.error('Origin is not a String type');
			};
		} else{
			window.console.error('Origin is undefined or null');
		};
	});
}

/************************************************************************
*	Description: Takes two inputs that has the first name and the last	*
*	name, and generates a full name with the two values.				*
*	Parameter:															*
*		fullNameTarget: selector where the value of the full name		*
*			should be.													*
*		firstNameTarget: selector where the value of the first name is.	*
*		lastNameTarget: selector where the value of the last name is.	*
*		form: (optional) selector of the form which the inputs belongs	*
************************************************************************/
function compose_name (fullNameTarget, firstNameOrigin, lastNameOrigin, form) {
	var fullNameObject, firstNameObject, lastNameObject;
	if (typeof form == "undefined" && form == null) {
		fullNameObject = $(fullNameTarget);
		firstNameObject = $(firstNameOrigin);
		lastNameObject = $(lastNameOrigin);
	} else{
		var form = $(form);
		fullNameObject = form.find(fullNameTarget);
		firstNameObject = form.find(firstNameOrigin);
		lastNameObject = form.find(lastNameOrigin);
	};
	var firstName = firstNameObject.val();
	var lastName = lastNameObject.val();
	var fullName = firstName + ' ' + lastName;
	fullNameObject.val(fullName.trim());
}