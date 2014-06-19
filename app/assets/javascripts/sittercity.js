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
      //  http://jonthornton.github.io/jquery-timepicker/
      //  http://jonthornton.github.io/jquery-timepicker/
      // initialize input widgets first 

      $('#durationPair .time').timepicker({
          'showDuration': true,
          'timeFormat': 'g:ia',
          'step': 15,
          'forceRoundTime': true
          
      });
      
      $('#durationPair .date').datepicker({
          'format': 'yyyy-m-d',
          'autoclose': true
      });
      
      // initialize datepair
      $('#durationPair').datepair();
      
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