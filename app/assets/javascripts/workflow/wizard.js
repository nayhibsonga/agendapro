var actualStep = 1;
var maxStep = 1;
var functions = new Array();

function prevStep() {
  var prev = actualStep - 1;

  if(prev >= 1){
    //Disable buttons
    $('#back_button').prop('disabled', true);
    $('#next_button').prop('disabled', true);

    //Actual step
    var step = '#step' + actualStep;
    var stepContent = '#step-content' + actualStep;

    //prev step
    var prevStep = '#step' + prev;
    var prevStepContent = '#step-content' + prev;

    /**** Wizard - Bar ****/
    $(step).removeClass('active');
    $(prevStep).removeClass('complete').addClass('active');

    /**** Wizard - Content ****/
    $(prevStepContent).parent().addClass('active');
    $(stepContent).collapse('toggle');
    $(prevStepContent).collapse('toggle');
    $(prevStepContent).on('shown.bs.collapse', function () {
      $(stepContent).parent().removeClass('active');

      //Eneable buttons
      $('#back_button').prop('disabled', false);
      $('#next_button').prop('disabled', false);
    });

    actualStep--;
    if(actualStep == 1) {
      $('#back_button').prop('disabled', true);
      //Revisar porque no funciona!!!
    }

    $('#next_button span').text("Siguiente");
  }
}

function nextStep() {
  var next = actualStep + 1;

  //Excecute load function
  try {
    if(functions[next - 1]()) {
      if(next <= maxStep){
        //Disable buttons
        $('#back_button').prop('disabled', true);
        $('#next_button').prop('disabled', true);

        //Actual step
        var step = '#step' + actualStep;
        var stepContent = '#step-content' + actualStep;

        //Next step
        var nextStep = '#step' + next;
        var nextStepContent = '#step-content' + next;

        /**** Wizard - Bar ****/
        $(step).removeClass('active').addClass('complete');
        $(nextStep).addClass('active');

        /**** Wizard - Content ****/
        $(nextStepContent).parent().addClass('active');
        $(stepContent).collapse('toggle');
        $(nextStepContent).collapse('toggle');
        $(stepContent).on('hidden.bs.collapse', function () {
          $(stepContent).parent().removeClass('active');

          //Eneable buttons
          $('#back_button').prop('disabled', false);
          $('#next_button').prop('disabled', false);
        });

        actualStep++;
        if(actualStep == maxStep) {
          $('#next_button span').text("Terminar");
        }
      }
    }
  }
  catch (err) {
    alert('Error cargando\n');
  }
}

function stepClick(id) {
  if(id < actualStep) {
    //Disable buttons
    $('#back_button').prop('disabled', true);
    $('#next_button').prop('disabled', true);

    var tmp = actualStep - 1;
    while (tmp > id) {
      var tmpStep = '#step' + tmp;
      $(tmpStep).removeClass('complete')
      tmp--;
    }
    $('#next_button span').text("Siguiente");

    //Actual step
    var step = '#step' + actualStep;
    var stepContent = '#step-content' + actualStep;

    //prev step
    var prevStep = '#step' + id;
    var prevStepContent = '#step-content' + id;

    /**** Wizard - Bar ****/
    $(step).removeClass('active');
    $(prevStep).removeClass('complete').addClass('active');

    /**** Wizard - Content ****/
    $(prevStepContent).parent().addClass('active');
    $(stepContent).collapse('toggle');
    $(prevStepContent).collapse('toggle');
    $(prevStepContent).on('shown.bs.collapse', function () {
      $(stepContent).parent().removeClass('active');
      
      //Eneable buttons
      $('#back_button').prop('disabled', false);
      $('#next_button').prop('disabled', false);
    });

    actualStep = id;
    //alert("actualStep: " + actualStep)
    if(actualStep == 1) {
      $('#back_button').prop('disabled', true);
    }
  }
}

$(function() {
  //Search elements and function of the wizard
  var count = 1;
  while (count) {
    var step = '#step' + count;
    var stepContent = '#step-content' + count;
    if($(step).length && $(stepContent).length){
      //detect element
      maxStep = count;
      $(step).on('click', function(event) {
        var id;
        if (event.target.getAttribute('id') != null) {
          id = event.target.getAttribute('id');
        }
        else {
          id = event.target.parentNode.getAttribute('id');
        }
        id = parseInt(id.replace('step', ''));
        stepClick(id);
      });

      //Detect function
      var fnName = 'loadStep' + count;
      functions.push(window[fnName]);

      count++;
    }
    else {
      count = 0;
    }
  }

  //Add finish method
  var fnName = 'finalize';
  functions.push(window[fnName]);

  //Active the first element of the wizard
  var step = '#step' + actualStep;
  var stepContent = '#step-content' + actualStep;
  $(step).addClass('active');
  $(stepContent).parent().addClass('active');
  try {
      functions[0]();
    }
    catch (err) {
      alert('Error cargando\n');
    }
});