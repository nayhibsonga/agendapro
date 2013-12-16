/**
Common Validation functions 
version 1.0


**/

function is_url(incomingString){
 
    var RegExp = /^(([\w]+:)?\/\/)?(([\d\w]|%[a-fA-f\d]{2,2})+(:([\d\w]|%[a-fA-f\d]{2,2})+)?@)?([\d\w][-\d\w]{0,253}[\d\w]\.)+[\w]{2,4}(:[\d]+)?(\/([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)*(\?(&?([-+_~.\d\w]|%[a-fA-f\d]{2,2})=?)*)?(#([-+_~.\d\w]|%[a-fA-f\d]{2,2})*)?$/; 
    if(RegExp.test(incomingString))
    { 
        return true;
    }
    else
    { 
        return false;
    }
}

function is_empty(str){
	
	if(str=='' || str==null){
		return 1;
	}else{
		return 0;
	}
}

function is_email(str){
	if(str.indexOf('@') == -1 || str.indexOf('.') == -1) {
		return 0;
	}
	return 1;

}

function is_equal(value1, value2) {
		if ($value1 == $value2)
		return 1;
		else
		return 0;
	}
	
// clear all form fields taking id of from like #frmLogin
function clearFormData(frm) {
	var $form = $(frm);
	$form.find(':input').each(function() {
		switch(this.type){
			case 'password':
			case 'select-multiple':
			case 'select-one':
			case 'text':
			case 'textarea':
			$(this).val('');
			break;
			case 'checkbox':
			case 'radio':
			this.checked = false;
		}
	});
}