function rut_split(value) {
	var cValue = rut_clear(value);
	if(cValue.length == 0) return [null, null];
	if(cValue.length == 1) return [cValue, null];
	var cDv = cValue.charAt(cValue.length - 1);
	var cRut = cValue.substring(0, cValue.length - 1);
	return [cRut, cDv];
};

function rut_format(value) {
	rutAndDv = rut_split(value);
	var cRut = rutAndDv[0]; var cDv = rutAndDv[1];
	if(!(cRut && cDv)) return cRut || value;
	var rutF = "";
	while(cRut.length > 3) {
		rutF = "." + cRut.substr(cRut.length - 3) + rutF;
		cRut = cRut.substring(0, cRut.length - 3);
	}
	return cRut + rutF + "-" + cDv;
}

function rut_clear(value) {
	return value.replace(/[\.\-]/g, "");
}

function validaRut(campo){
	if ( campo.length == 0 ){ return false; }
	if ( campo.length < 8 ){ return false; }
 
	campo = campo.replace('-','')
	campo = campo.replace(/\./g,'')
 
	var suma = 0;
	var caracteres = "1234567890kK";
	var contador = 0;    
	for (var i=0; i < campo.length; i++){
		u = campo.substring(i, i + 1);
		if (caracteres.indexOf(u) != -1)
		contador ++;
	}
	if ( contador==0 ) { return false }
	
	var rut = campo.substring(0,campo.length-1)
	var drut = campo.substring( campo.length-1 )
	var dvr = '0';
	var mul = 2;
	
	for (i= rut.length -1 ; i >= 0; i--) {
		suma = suma + rut.charAt(i) * mul
                if (mul == 7) 	mul = 2
		        else	mul++
	}
	res = suma % 11
	if (res==1)		dvr = 'k'
                else if (res==0) dvr = '0'
	else {
		dvi = 11-res
		dvr = dvi + ""
	}
	if ( dvr != drut.toLowerCase() ) { return false; }
	else { return true; }
}
 
/* La siguiente instrucción extiende las capacidades de jquery.validate() para que
	admita el método RUT, por ejemplo:
 
$('form').validate({
	rules : { rut : { required:true, rut:true} } ,
	messages : { rut : { required:'Escriba el rut', rut:'Revise que esté bien escrito'} }
})
// Nota: el meesage:rut sobrescribe la definición del mensaje de más abajo
*/
// comentar si jquery.Validate no se está usando

$.validator.addMethod("rut", function(value, element) { 
        return this.optional(element) || validaRut(value); 
}, "RUT incorrecto");