(function() {
  var model;
  
  // Unlike the sister validator "exclusion", I'm not using allow_blank in the test
  // because blank sure as heck is not included in the list.  I still below test the
  // usual use case that you'll want to use both inclusion and presence validators
  // together to provide more meaningful error messages.
  module("inclusion", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'inclusion', in: ['small', 'medium', 'large'] }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when null", function() {
      model.populate({ email: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when blank", function() {
      model.populate({ email: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when extra large", function() {
      model.populate({ my_field: "extra large" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("passes when small", function() {
      model.populate({ my_field: "small" });
      ok (model.isValid());
    });

    test("passes when medium", function() {
      model.populate({ my_field: "medium" });
      ok (model.isValid());
    });

    test("passes when large", function() {
      model.populate({ my_field: "large" });
      ok (model.isValid());
    });


  module("inclusion with a separate presence test", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: [
            { test: 'inclusion', in: ['small', 'medium', 'large'], allow_blank: true },
            { test: 'presence' }
          ]
        }
      ];
    }
  });


    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "My field can't be empty");
    });

    test("fails when null", function() {
      model.populate({ email: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "My field can't be empty");
    });
    
    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "My field can't be empty");
    });

    test("fails when extra large", function() {
      model.populate({ my_field: "extra large" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("passes when small", function() {
      model.populate({ my_field: "small" });
      ok (model.isValid());
    });

    test("passes when medium", function() {
      model.populate({ my_field: "medium" });
      ok (model.isValid());
    });

    test("passes when large", function() {
      model.populate({ my_field: "large" });
      ok (model.isValid());
    });


  // Make sure it doesn't bomb if the client forgot to supply an "in" array.
  // Nothing should pass.
  module("inclusion with no 'in' list provided", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'inclusion' }
        }
      ];
    }
  });



    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when null", function() {
      model.populate({ email: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when blank", function() {
      model.populate({ email: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when extra large", function() {
      model.populate({ my_field: "extra large" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when large", function() {
      model.populate({ my_field: "large" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when medium", function() {
      model.populate({ my_field: "medium" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });

    test("fails when small", function() {
      model.populate({ my_field: "small" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is not included in the list');
    });



})();
