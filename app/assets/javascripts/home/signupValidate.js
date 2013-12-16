$(function() {
    console.log("Signup Validate")
    $('#frmSignup').validate({
        errorPlacement: function(error, element) {
            if (element.attr("id")=='terms') {
                error.appendTo(element.next().next());
            }
            else {
                error.appendTo(element.next());
            }
        },
        onkeyup: false,
        rules: {
            name: {
                required: true,
                minlength: 3,
                remote: "index.php?task=company_checkcompanyname"
            },
            first_name: {
                required: true,
                minlength: 3
            },
            last_name: {
                required: true,
                minlength: 3
            },
            email: {
                required: true,
                email: true
            },
            user_name: {
                required: true,
                minlength: 3
            },
            password: {
                required: true,
                minlength: 4
            },
            c_password: {
                required: true,
                minlength: 4,
                equalTo: "#password"
            },
            web_address: {
                required: true,
                minlength: 3,
                remote: "index.php?task=company_checkwebaddress"// remote check for duplicate web_address
            },
            phone: {
                required: true,
                minlength: 7,
                maxlength: 12
            },
            logo: {
                accept: "jpe?g|png|gif|bmp",
                filesize: 2097152
            },
            terms: {
                required: true
            }
        },
        messages: {
            name: {
                required: "Es requerido un nombre de la compa&ntilde;&iacute;a",
                minlength: "El nombre debe tener al menos 3 caract&eacute;res",
                remote: jQuery.validator.format("{0} ya fue utilizado")
            },
            first_name: {
                required: "Es requerido su nombre",
                minlength: "El nombre debe tener al menos 3 caract&eacute;res"
            },
            last_name: {
                required: "Es requerido su apellido",
                minlength: "El apellido debe tener al menos 3 caract&eacute;res"
            },
            user_name: {
                required: "Es requerido un nombre de usuario",
                minlength: "Username debe tener al menos 3 caract&eacute;res"
            },
            email: {
                required: "Por favor ingrese un email v&aacute;lido",
                email: "Por favor ingrese un email v&aacute;lido"
            },
            password: {
                required: "Debe ingresar una contrase&ntilde;a",
                minlength: "La contrase&ntilde;a debe tener al menos 4 caract&eacute;res"
            },
            c_password: {
                required: "Debe confirmar su contrase&ntilde;a",
                minlength: "La contrase&ntilde;a debe tener al menos 4 caract&eacute;res",
                equalTo: "La contrase&ntilde;a no coincide"
            },
            web_address: {
                required: "Es necesario ingresar una direcci&oacute;n web",
                minlength: "La direcci&oacute;n debe tener al menos 3 caract&eacute;res",
                remote: jQuery.validator.format("{0} ya fue utilizado")
            },
            phone: {
                required: "Es necesario ingresar un tel&eacute;fono",
                minlength: "El tel&eacute;fono es muy corto",
                maxlength: "El tel&eacute;fono es muy largo"
            },
            logo: {
                accept: "Formatos permitidos: JPG, GIF, PNG y BMP",
                filesize: "La im&aacute;gen no puede superar los 2 MB"
            },
            terms: {
                required: "Es necesario aceptar los t&eacute;rminos y condiciones."
            }
        },
        highlight: function(element) {
            $(element).closest('.form-group').removeClass('has-success').addClass('has-error');
        },
        success: function(element) {
            $(element).closest('.form-group').removeClass('has-error').addClass('has-success');
        },
        submitHandler: function(form) {
            form.submit();
        }
    });
    $.validator.addMethod("alphaNumeric", function(value, element) {
        return this.optional(element) || /^\s*[a-zA-Z0-9,\s]+\s*$/i.test(value); // letters, digits,',- and space.
    }, "No se pueden usar caract&eacute;res especiales");
    $.validator.addMethod('filesize', function(value, element, param) {
        // param = size (en bytes) 
        // element = element to validate (<input>)
        // value = value of the element (file name)
        return this.optional(element) || (element.files[0].size <= param) 
    });
    $('#name').one('change', function() {
        var tmp = $('#name').val();
        tmp = tmp.replace(/ /g, '');
        tmp = tmp.toLowerCase();
        $('#web_address').val(tmp);
    });
});