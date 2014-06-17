/*!
 * Sittercity v0.0.1
 * 
 * Copyright 2014 Sittercity Incorporated
 * Implementation of the Garber-Irish model:  http://viget.com/inspire/extending-paul-irishs-comprehensive-dom-ready-execution
 * 
 */

DOC_LOAD_ACTIONS_CONFIG = {
  common: {
    init: function() {
    // site-wide code
    }
  },
  
  members: {
    init: function() {
      // controller-wide code
    },
    
    settle_up: function() {
      // load the cropzoom toolset
      $('#started_at_timepicker').timepicker({dateFormat: 'mm/dd/yy'});
      $('#ended_at_timepicker').timepicker({dateFormat: 'mm/dd/yy'});
    },
  },
  
};
 
//base controller functionality;  this should not need modification
UTIL = {
  exec: function( controller, action ) {
    var ns = DOC_LOAD_ACTIONS_CONFIG,
        action = ( action === undefined ) ? "init" : action;
 
    if ( controller !== "" && ns[controller] && typeof ns[controller][action] == "function" ) {
      ns[controller][action]();
    }
  },
 
  init: function() {
    var body = document.body,
        controller = body.getAttribute( "data-controller" ),
        action = body.getAttribute( "data-action" );
 
    UTIL.exec( "common" );
    UTIL.exec( controller );
    UTIL.exec( controller, action );
  }
};
 
$( document ).ready( UTIL.init );