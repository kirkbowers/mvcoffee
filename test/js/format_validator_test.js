(function() {
  var model;
  
  module("format", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'format', with: /^[a-zA-Z]+$/ }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("fails when letters and numbers", function() {
      model.populate({ my_field: "abc123" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("fails when letters and punctuation", function() {
      model.populate({ my_field: "Stop!" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("fails when letters and whitespace", function() {
      model.populate({ my_field: "   island   " });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("passes when only letters", function() {
      model.populate({ my_field: "Fluffy" });
      ok (model.isValid());
    });

  // Make sure it doesn't bomb if the client forgot to supply an "with" regexp.
  // Everything should pass except null and undefined
  module("format with no 'with' regexp provided", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'format' }
        }
      ];
    }
  });


    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("passes when blank", function() {
      model.populate({ my_field: "" });
      ok (model.isValid());
    });

    test("passes when letters and numbers", function() {
      model.populate({ my_field: "abc123" });
      ok (model.isValid());
    });

    test("passes when letters and punctuation", function() {
      model.populate({ my_field: "Stop!" });
      ok (model.isValid());
    });

    test("passes when letters and whitespace", function() {
      model.populate({ my_field: "   island   " });
      ok (model.isValid());
    });

    test("passes when only letters", function() {
      model.populate({ my_field: "Fluffy" });
      ok (model.isValid());
    });



})();