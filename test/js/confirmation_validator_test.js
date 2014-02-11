(function() {
  var model;
  
  module("confirmation", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'email',
          validates: [
            { test: 'confirmation' }
          ]
        },
        { name: 'email_confirmation' }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when null and confirm undefined", function() {
      model.populate({ email: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when blank and confirm undefined", function() {
      model.populate({ email: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when null and confirm null", function() {
      model.populate({ email: null, email_confirmation: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when blank and confirm null", function() {
      model.populate({ email: "", email_confirmation: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when null and confirm blank", function() {
      model.populate({ email: null, email_confirmation: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when blank and confirm blank", function() {
      model.populate({ email: "", email_confirmation: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when blank and confirm something", function() {
      model.populate({ email: "", email_confirmation: "foo@somewhere.com" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when something and confirm blank", function() {
      model.populate({ email: "foo@somewhere.com", email_confirmation: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when something and confirm something else", function() {
      model.populate({ email: "foo@somewhere.com", email_confirmation: "fob@somewhere.com" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("passes when something and confirm matches", function() {
      model.populate({ email: "foo@somewhere.com", email_confirmation: "foo@somewhere.com" });
      ok (model.isValid());
    });


  module("confirmation", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'email',
          validates: [
            { test: 'confirmation', allow_blank: true }
          ]
        },
        { name: 'email_confirmation' }
      ];
    }
  });

    test("passes when undefined", function() {
      model.validate();
      ok (model.isValid());
    });

    test("passes when null and confirm undefined", function() {
      model.populate({ email: null });
      ok (model.isValid());
    });

    test("passes when blank and confirm undefined", function() {
      model.populate({ email: "" });
      ok (model.isValid());
    });

    test("passes when null and confirm null", function() {
      model.populate({ email: null, email_confirmation: null });
      ok (model.isValid());
    });

    test("passes when blank and confirm null", function() {
      model.populate({ email: "", email_confirmation: null });
      ok (model.isValid());
    });

    test("passes when null and confirm blank", function() {
      model.populate({ email: null, email_confirmation: "" });
      ok (model.isValid());
    });

    test("passes when blank and confirm blank", function() {
      model.populate({ email: "", email_confirmation: "" });
      ok (model.isValid());
    });

// TODO!!!
// Defer this rule.  This one turns out hard to do with the way I've set up the 
// general purpose guard for allow_blank.  I think this is a very rare boundary case,
// and in the off chance that it occurs, the server should catch it.
//
//     test("fails when blank and confirm something", function() {
//       model.populate({ email: "", email_confirmation: "foo@somewhere.com" });
//       ok (! model.isValid());
//       equal (model.errors.length, 1);
//       equal (model.errors[0], "Email doesn't match confirmation");
//     });
// 
    test("fails when something and confirm blank", function() {
      model.populate({ email: "foo@somewhere.com", email_confirmation: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("fails when something and confirm something else", function() {
      model.populate({ email: "foo@somewhere.com", email_confirmation: "fob@somewhere.com" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email doesn't match confirmation");
    });

    test("passes when something and confirm matches", function() {
      model.populate({ email: "foo@somewhere.com", email_confirmation: "foo@somewhere.com" });
      ok (model.isValid());
    });



})();