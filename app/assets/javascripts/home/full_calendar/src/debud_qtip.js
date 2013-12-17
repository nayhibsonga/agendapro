
/* DEBUG MODE - OFF BY DEFAULT - set to true to enable debugging */
$.fn.qtip.debug = false;


if($.fn.qtip.debug)
{
   // Create new debug constants
   $.fn.qtip.constants =
   {
      /* Error messages */
      NO_TOOLTIP_PRESENT: 'No tooltip is present on the selected element. Cannot proceed with API call.',
      TOOLTIP_NOT_RENDERED: 'Tooltip has not yet been rendered! Cannot proceed with API call.',
      NO_VALID_CONTENT: 'No valid content was provided in the options. Using blank content.',
      TOOLTIP_IS_DISABLED: 'Tooltip is disabled, cannot proceed with API call.',
      TOOLTIP_ALREADY_DISABLED: 'Tooltip is already disabled.',
      TOOLTIP_ALREADY_ENABLED: 'Tooltip is already enabled.',
      CANVAS_VML_NOT_SUPPORTED: 'Niether canvas or VML are supported, corner and tips will not be drawn.',
      STYLE_NOT_DEFINED: 'No such style is defined in the global styles object.',
      INVALID_AREA_SHAPE: 'The AREA element used as your target has an invalid area shape. Possible values are: rect, circle, poly.',
      CANNOT_FOCUS_STATIC: 'Focusing static elements is not possible as they don\'t have z-index properties.',
      CANNOT_POSITION_STATIC: 'Positioning static elements is not possible as they don\'t have left or top properties.',
      NO_CONTENT_PROVIDED: 'You must specify some content with which to update.',

      /* Event messages */
      EVENT_RENDERED: '(Event) Tooltip has been rendered.',
      EVENT_SHOWN: '(Event) Tooltip has been shown.',
      EVENT_HIDDEN: '(Event) Tooltip has been hidden.',
      EVENT_FOCUSED: '(Event) Tooltip has been focused.',
      EVENT_DISABLED: '(Event) Tooltip has been disabled.',
      EVENT_ENABLED: '(Event) Tooltip has been enabled.',
      EVENT_DESTROYED: '(Event) Tooltip has been destroyed.',
      EVENT_POSITION_UPDATED: '(Event) Tooltip position has been updated.',
      EVENT_CONTENT_UPDATED: '(Event) Tooltip contents have been updated.',
      EVENT_CONTENT_LOADED: '(Event) Tooltip contents have been loaded from specified URL.',
      EVENT_TITLE_UPDATED: '(Event) Tooltip title has been updated.',
      EVENT_STYLE_UPDATED: '(Event) Tooltip style has been updated.',
      EVENT_WIDTH_UPDATED: '(Event) Tooltip width has been updated.'
   };

   // Define qTip log object
   $.fn.qtip.log = {
      /* CONSOLE REPORTING MASK
         To use this functionality you need a console installed, such as firebug:
            http://getfirebug.com

         This mask determines what errors are reported to the console. Possible values are:
            7 = Errors, warnings and messages
            6 = Errors and warnings
            5 = Errors and messages
            4 = Errors only
            3 = Warnings and messages
            2 = Warnings only
            1 = Messages only
      */
      report: 7,

      /* DO NOT ALTER ANYTHING BELOW HERE! */
      qtips: [],
      messages: [],
      errors: [],

      /* Error handler function */
      error: function(type, message, method)
      {
         var self = this;

         // Format type string
         switch(type)
         {
            case 1:
               var typeString = 'info';
               var addTo = 'messages';
               break;

            case 2:
               var typeString = 'warn';
               var addTo = 'messages';
               break;

            default: case 4:
               var typeString = 'error';
               var addTo = 'errors';
               break;
         }

         // Format time
         var DateObj = new Date();
         var time = DateObj.getHours() + ':' +
                     DateObj.getMinutes() + ':' +
                     DateObj.getSeconds();

         // Log the error into the log array
         $.fn.qtip.log[addTo].push({
            time: time,
            message: message,

            api: self,
            callee: self[method] || method || null
         });

         // If debug mode is enabled, display the error
         if($.fn.qtip.log.report & type > 0)
         {
            var logMessage = 'qTip '
               + ((typeof self.id !== 'undefined') ? '['+self.id+']' : '')
               + ': ' + message;

            // Check console is present
            if(window.console) window.console[typeString](logMessage);

            // Check for Opera Dragonfly
            else if($.browser.opera && window.opera.postError) window.opera.postError(logMessage);
         }

         return self;
      }
   };
};
