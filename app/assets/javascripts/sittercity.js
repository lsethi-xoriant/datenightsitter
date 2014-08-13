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
  
  date_night_slots: {
    init: function() {
      $('.time').timepicker({
          'timeFormat': 'g:i A',
          'step': 15,
          'forceRoundTime': true,
          'scrollDefaultNow': true,
          'disableTouchKeyboard':true
      });

      $('.date').datepicker({
        format: "yyyy-mm-dd",
        daysOfWeekDisabled: "0,1,2,3,4",
        todayHighlight: true
      });
    },
    
    new: {
      
    }
    
  },
  
  members: {
    init: function() {
      // controller-wide code
    },
    
    bank_account: function() {
      var braintree = Braintree.create(BRAINTREE_PAYMENT_CSE);
      braintree.onSubmitEncryptForm('braintree-merchant-form');
    },
    
    date_night_availability: function() {
      //trigger the parent form submit on select field change
      $("form.new_date_night_sitting select").change( function() {
        $(this).closest("form").submit();  
      });
      
      //hide the submit button
      $("form.new_date_night_sitting input[type='submit']").hide();
      
      //on successful submission, reload page
      $('form.new_date_night_sitting').on(
        'ajax:success',
        function(event, data, status, xhr) {
          console.log(data);
          document.location.href = "date_night_availability";
          return false;
        });
        
    },
    
    settle_up: function() {
      //  http://jonthornton.github.io/jquery-timepicker/
      //  http://jonthornton.github.io/jquery-datepair/

      // initialize input widgets first 
      $('#durationPair .time').timepicker({
          'showDuration': true,
          'timeFormat': 'g:i A T',
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
  },
  
  date_night_sittings: {
    init: function() {
      //controller-wide code
    },
    
    create: function() {
      
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