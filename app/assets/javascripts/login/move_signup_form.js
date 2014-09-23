$('#btnNext').click(function(){
  $('.nav-tabs > .active').next('li').addClass('active');
  $('.nav-tabs > .active').first().removeClass('active');
});
