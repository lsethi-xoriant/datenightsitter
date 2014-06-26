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
      //  http://jonthornton.github.io/jquery-datepair/

      // initialize input widgets first 
      $('#durationPair .time').timepicker({
          'showDuration': true,
          'timeFormat': 'g:ia',
          'step': 30,
          'forceRoundTime': true,
          'scrollDefaultNow': true,
          'disableTouchKeyboard':true
      });
      
      // initialize datepair
      $("#durationPair").datepair( {"defaultTimeDelta":14400000 } );

      //add datepair event handlers
      $('#durationPair').on('rangeSelected', function() {
        hours = $("#durationPair").datepair('getTimeDiff') /  3600000; // in hours
        $('#transaction_duration').val( Number(hours) );  //update duration
      });
      
      //add started at event handlers
      $('#started_at').change(function() {
        v = $('#started_at').timepicker('getTime');
        $('#transaction_started_at').val( v );
      });
      
      //set default values
      if ( $('#transaction_started_at').val().length > 1 ){
        dStart = new Date( Date.parse( $('#transaction_started_at').val() ) );
        iDuration = Number ( $('#transaction_duration').val() );
        dEnd = new Date(dStart);
        dEnd.setHours(dEnd.getHours() + iDuration );
        
        $('#started_at').timepicker('setTime', dStart);
        $('#ended_at').timepicker('setTime', dEnd);
      }
    },
  },
  
  transactions: {
    init: function() {
      //controller-wide code
    },
    review: function() {
      var braintree = Braintree.create(BRAINTREE_PAYMENT_CSE);
      braintree.onSubmitEncryptForm('braintree-payment-form');
      
      //provides bump up functionality
      $('#bump-up').click(function() {
        cur_val = $("#transaction_amount").val();
        amt = $('#bump-up').data('amount');
        new_val = Number(cur_val) + Number(amt);
        $("#transaction_amount").val(new_val);
        return true;
      });
      
      //provides round up functionality
      $('#round-up').click(function() {
        amt = $('#round-up').data('amount');
        $("#transaction_amount").val(Number(amt));
        return true;
      });
    }
  }
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