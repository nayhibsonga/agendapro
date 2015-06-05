/**
 * @license Copyright (c) 2003-2014, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here.
	// For complete reference see:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config

	/* Filebrowser routes */
  // The location of a script that handles file uploads in the Image dialog.
  // config.filebrowserImageUploadUrl = "/ckeditor/pictures";

  // Rails CSRF token
  config.filebrowserParams = function(){
    var csrf_token, csrf_param, meta,
      metas = document.getElementsByTagName('meta'),
      params = new Object();

    for ( var i = 0 ; i < metas.length ; i++ ){
      meta = metas[i];

      switch(meta.name) {
        case "csrf-token":
          csrf_token = meta.content;
          break;
        case "csrf-param":
          csrf_param = meta.content;
          break;
        default:
          continue;
      };
    };

    if (csrf_param !== undefined && csrf_token !== undefined) {
      params[csrf_param] = csrf_token;
    };

    return params;
  };

	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
		{ name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },
		{ name: 'editing',     groups: [ 'spellchecker' ] },
		{ name: 'links' },
		{ name: 'insert' },
		{ name: 'styles' },
		'/',
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'colors' },
		{ name: 'paragraph',   groups: [ 'list', 'indent', 'blocks', 'align' ] },
		{ name: 'tools', groups: ['maximize', 'mode'] }
	];

	// Remove some buttons provided by the standard plugins, which are
	// not needed in the Standard(s) toolbar.
	config.removeButtons = 'Subscript,Superscript,CreateDiv,Flash,PageBreak,Iframe,ShowBlocks,Smiley';

	// Set the most common block elements.
	config.format_tags = 'p;h1;h2;h3;pre';

	// Simplify the dialog windows.
	config.removeDialogTabs = 'image:advanced;link:advanced';

	// Load the Spanish interface.
	config.language = 'es';
	// Changes magic line color to blue.
	CKEDITOR.config.magicline_color = '#22c488';
	// Enables the greedy "put everywhere" mode.
	CKEDITOR.config.magicline_everywhere = true;
	// Number of space inserted by Tab
	config.tabSpaces = 2;
};

