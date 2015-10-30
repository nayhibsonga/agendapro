/* 
 Modal Alert

 It's a better way to show alerts to the user.

 Usage:
 * Create a new alert: new Alert(appendTo)
 	- appendTo: where the modal is inserted.
    The appendTo parameter, indicate where to insert the Modal Alert. If nothing is provide, it will append to the body.
 * Show the alert: Alert.showAlert(message, close_function, close_text)
	- message: the message to show. Can contain html text.
	- close_function: a function that will be call when the user acepts the message by clicking on the button.
	- close_text: the text of the button that call the close_function
	The alert is shown to the user with the message and a single button to close the alert. If a close_function is provide, the alert will have a second button that close the alert and trigger the function.

 Dependecies:
 * Twitter Bootstrap v3.0.0
 * jQuery v1.10.2

 Copyrights NicoFlores.
 */


// Object Alert
function Alert (appendTo) {
	// Default Value
	appendTo = appendTo || 'body';


	//==== Insert the Alert ====//
	$(function () {
		// Search for other Alert instance
		var instance = $('#alertModal');
		if (instance.length == 0) {
			// Insert the Alert
			$(appendTo).prepend(
				'<div class="modal fade"  id="alertModal" tabindex="-1" role="dialog" aria-labelledby="alertLabel" aria-hidden="true">' +
				  '<div class="modal-dialog">' +
				    '<div class="modal-content">' +
				      '<div class="modal-body">' +
				        '<div id="alertBody"></div>' +
				      '</div>' +
				      '<div class="modal-footer">' +
				        '<button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>' +
				      '</div>' +
				    '</div><!-- /.modal-content -->' +
				  '</div><!-- /.modal-dialog -->' +
				'</div><!-- /.modal -->'
			);
		}
	});

	//==== Private Methods ====//
	// Show - Hide methods
	var show = function () {
		$('#alertModal').modal('show');
	}

	var hide = function () {
		$('#alertModal').modal('hide');
	}

	//==== Public Methods ====//
	this.showAlert = function (message, close_function, close_text, hide_function) {
		// Modal Body
		$('#alertModal #alertBody').html(message);

		// Modal Footer
		close_function = close_function || null;
		hide_function = hide_function || null;
		close_text = close_text || 'Aceptar';
		if (close_function) {
			$('#alertModal .modal-footer').append(
				'<button type="button" class="btn btn-info" id="closeModal">' + close_text + '</button>'
			);
			$('#alertModal #closeModal').click(function (e) {
				hide();
				close_function();
			});
			$('#alertModal').on('hidden.bs.modal', function (e) {
				$('#alertModal #closeModal').remove();
			});
		}

		if(hide_function){
			$('#alertModal').on('hidden.bs.modal', function (e) {
				hide_function();
				$('#alertModal #closeModal').remove();
			});
		}

		show();
	}
}
