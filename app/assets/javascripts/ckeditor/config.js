/**
 * @license Copyright (c) 2003-2014, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here.
	// For complete reference see:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config

	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
		{ name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },
		{ name: 'editing',     groups: [ 'spellchecker' ] },
		{ name: 'links' },
		{ name: 'insert' },
		{ name: 'tools', groups: ['maximize', 'mode'] },
		'/',
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'paragraph',   groups: [ 'list', 'indent', 'blocks', 'align' ] },
		'/',
		{ name: 'styles' },
		{ name: 'colors' }
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

