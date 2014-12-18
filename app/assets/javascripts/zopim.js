window.$zopim||(function(d,s){var z=$zopim=function(c){z._.push(c)},$=z.s=
		d.createElement(s),e=d.getElementsByTagName(s)[0];z.set=function(o){z.set.
		_.push(o)};z._=[];z.set._=[];$.async=!0;$.setAttribute('charset','utf-8');
		$.src='//v2.zopim.com/?2PvkM64HzukqpnkqZn4SzQNPC6ujVyoE';z.t=+new Date;$.
		type='text/javascript';e.parentNode.insertBefore($,e)})(document,'script');

$zopim(function() {
    $zopim.livechat.button.show();
});

$(window).on('shown.bs.modal', function() {
    $zopim.livechat.hideAll();
});

$(window).on('hidden.bs.modal', function() {
    $zopim.livechat.button.show();
});