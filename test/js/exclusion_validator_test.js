(function() {
  var model;
  
  // I'm using the allow blank flag in this test suite because I just can't see a use
  // case in which you wouldn't either allow blank (because it is, in fact, not in the
  // array of disallowed values), or you'd enforce non-blank with a separate presence
  // test in order to make the error message more meaningful.
  module("exclusion", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'exclusion', in: ['www', 'us', 'ca', 'jp'], allow_blank: true }
        }
      ];
    }
  });

    test("fails when www", function() {
      model.populate({ my_field: "www" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is reserved');
    });

    test("fails when us", function() {
      model.populate({ my_field: "us" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is reserved');
    });

    test("fails when ca", function() {
      model.populate({ my_field: "ca" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is reserved');
    });

    test("fails when jp", function() {
      model.populate({ my_field: "jp" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is reserved');
    });

    test("passes when wwww", function() {
      model.populate({ my_field: "wwww" });
      ok (model.isValid());
    });

    test("passes when something completely different", function() {
      model.populate({ my_field: "something completely different" });
      ok (model.isValid());
    });

    test("passes when blank", function() {
      model.populate({ my_field: "" });
      ok (model.isValid());
    });

  module("exclusion with separate presence validator", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: [
            { test: 'exclusion', in: ['www', 'us', 'ca', 'jp'], allow_blank: true },
            { test: 'presence' }
          ]
        }
      ];
    }
  });

    test("fails when www", function() {
      model.populate({ my_field: "www" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is reserved');
    });

    test("fails when us", function() {
      model.populate({ my_field: "us" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is reserved');
    });

    test("fails when ca", function() {
      model.populate({ my_field: "ca" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is reserved');
    });

    test("fails when jp", function() {
      model.populate({ my_field: "jp" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is reserved');
    });

    test("passes when wwww", function() {
      model.populate({ my_field: "wwww" });
      ok (model.isValid());
    });


    test("passes when something completely different", function() {
      model.populate({ my_field: "something completely different" });
      ok (model.isValid());
    });
    
    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "My field can't be empty");
    });

  // Make sure it doesn't bomb if the client forgot to supply an "in" array.
  // Everything should pass.
  module("exclusion with no 'in' list provided", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'exclusion', allow_blank: true }
        }
      ];
    }
  });


    test("passes when www", function() {
      model.populate({ my_field: "www" });
      ok (model.isValid());
    });

    test("passes when wwww", function() {
      model.populate({ my_field: "wwww" });
      ok (model.isValid());
    });

    test("passes when something completely different", function() {
      model.populate({ my_field: "something completely different" });
      ok (model.isValid());
    });
    
    test("passes when blank", function() {
      model.populate({ my_field: "" });
      ok (model.isValid());
    });



})();
