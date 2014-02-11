/*
 * This is the one test set of model validator tests that depends on a real model 
 * subclassed from MVCoffee.Model.  I'm doing it that way largely for completeness sake,
 * just to make sure that things do behave as expected when subclassing the Model class.
 * It turns out to be largely unnecessary and unwieldy, so in all other validator tests
 * I just create a new fields array and assign it to the fields property of a generic,
 * empty model.  This works just as well for exercising the validators.
 */

(function() {

  var model;

  module("presence", {
    setup: function() {
      model = new PresenceModel({
        present: 'a',
        present_with_display: 'b',
        present_with_message: 'c',
        present_with_unless: 'd'
      });
    }
  });

    test( "validates with all present", function() {
      ok( model.isValid() );
    });
  
    test( "fails with present null", function() {
      model.present = null;
      model.validate();
      ok( ! model.isValid() );
      equal(model.errors.length, 1);
      equal(model.errors[0], "Present can't be empty");
    });  
  
    test( "fails with present blank", function() {
      model.present = '';
      model.validate();
      ok( ! model.isValid() );
      equal(model.errors.length, 1);
      equal(model.errors[0], "Present can't be empty");
    });  
  
    test( "fails with present with display null", function() {
      model.present_with_display = null;
      model.validate();
      ok( ! model.isValid() );
      equal(model.errors.length, 1);
      equal(model.errors[0], "Display Name can't be empty");
    });  
  
    test( "fails with present with message null", function() {
      model.present_with_message = null;
      model.validate();
      ok( ! model.isValid() );
      equal(model.errors.length, 1);
      equal(model.errors[0], "Present with message must have a custom message");
    });
  
    test( "fails with present with unless null and function false", function() {
      model.present_with_unless = null;
      model.validate();
      ok( ! model.isValid() );
      equal(model.errors.length, 1);
      equal(model.errors[0], "Present with unless can't be empty");
    });
  
    test( "ok with present with unless present and function true", function() {
      model.skip = true;
      model.validate();
      ok( model.isValid() );
    });
  
    test( "ok with present with unless null and function true", function() {
      model.present_with_unless = null;
      model.skip = true;
      model.validate();
      ok( model.isValid() );
    });
  
})();
  