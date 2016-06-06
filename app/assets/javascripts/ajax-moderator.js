/*
 
Simple Moderator for ajax requests


The idea is to register overlapping ajax requests (only the last should be served) ona LIOO (last in only out) list.
Then, on ajax return, call for shouldDisplay to know if the response should be processed.
You can gather any amount of different functions (or just one that could catch up with itself) that shouldn't be displayed together under the same list identified by a name.

Use:

var name = "custom_name";
var name2 = "custom_name2";

$(document).ready(function(){
	registerModerator(name);
	registerModerator(name2);
});

function loadSomeOverlappingCall()
{
	var turn = requestAjaxTurn(name);

	$.ajax{
		.
		.
		.
		success: function(response){
			if(shouldDisplay(name, turn))
			{
				//Do something with the response...
			}
		}
	}

}

function loadOtherOverlappingCall()
{
	var turn = requestAjaxTurn(name);

	$.ajax{
		.
		.
		.
		success: function(response){
			if(shouldDisplay(name2, turn))
			{
				//Do something with the response...
			}
		}
	}

}

*/

var current_requests = [];

function registerModerator(name)
{
	current_requests[name] = 0;
}

function requestAjaxTurn(name){
	current_requests[name] += 1;
	return current_requests[name];
}

function shouldDisplay(name, turn)
{
	console.log("Current: " + current_requests[name]);
	console.log("Turn: " + turn);
	return current_requests[name] == turn;
}