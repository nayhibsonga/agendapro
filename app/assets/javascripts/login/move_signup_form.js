$('#btnNext').click(function(){
  $('.nav-tabs > .active').next('li').find('a').trigger('click');
});
