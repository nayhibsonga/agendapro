$zopim(function() {
    $zopim.livechat.button.show();
});

$(window).on('shown.bs.modal', function() {
    $zopim.livechat.hideAll();
});

$(window).on('hidden.bs.modal', function() {
    $zopim.livechat.button.show();
});