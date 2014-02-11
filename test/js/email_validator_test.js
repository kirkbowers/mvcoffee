(function() {
  var model;
  
  module("email and array of validates", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'email',
          validates: [
            { test: 'email' }
          ]
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when null", function() {
      model.populate({ email: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when blank", function() {
      model.populate({ email: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when no at signs", function() {
      model.populate({ email: "joe" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when no dot suffix", function() {
      model.populate({ email: "joe@foo" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });
    
    test("fails when two ats", function() {
      model.populate({ email: "joe@blow@foo.com" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });
    
    test("succeeds with good email", function() {
      model.populate({ email: "joe.blow@foo.com" });
      ok (model.isValid());
      equal (model.errors.length, 0);
    });


  module("email and object of one validate", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'email',
          validates: { test: 'email' }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when null", function() {
      model.populate({ email: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when blank", function() {
      model.populate({ email: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when no at signs", function() {
      model.populate({ email: "joe" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when no dot suffix", function() {
      model.populate({ email: "joe@foo" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });
    
    test("fails when two ats", function() {
      model.populate({ email: "joe@blow@foo.com" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });
    
    test("succeeds with good email", function() {
      model.populate({ email: "joe.blow@foo.com" });
      ok (model.isValid());
      equal (model.errors.length, 0);
    });


  module("email with display name", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'email',
          display: 'Email Address',
          validates: [
            { test: 'email' }
          ]
        }
      ];
    }
  });

    test("fails when no at signs", function() {
      model.populate({ email: "joe" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email Address must be a valid email address');
    });


  module("email with custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'email',
          validates: [
            { test: 'email', message: 'has a custom message' }
          ]
        }
      ];
    }
  });

    test("fails when no at signs", function() {
      model.populate({ email: "joe" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email has a custom message');
    });

  
  module("email allows null", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'email',
          validates: [
            { test: 'email', allow_null: true }
          ]
        }
      ];
    }
  });

    test("passes when undefined", function() {
      model.validate();
      ok (model.isValid());
      equal (model.errors.length, 0);
    });

    test("passes when null", function() {
      model.populate({ email: null });
      ok (model.isValid());
      equal (model.errors.length, 0);
    });

    test("fails when blank", function() {
      model.populate({ email: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when no at signs", function() {
      model.populate({ email: "joe" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("fails when no dot suffix", function() {
      model.populate({ email: "joe@foo" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });
    
    test("fails when two ats", function() {
      model.populate({ email: "joe@blow@foo.com" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });
    
    test("succeeds with good email", function() {
      model.populate({ email: "joe.blow@foo.com" });
      ok (model.isValid());
      equal (model.errors.length, 0);
    });


  module("email allows blank with presence test", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'email',
          validates: [
            { test: 'presence' },
            { test: 'email', allow_blank: true }
          ]
        }
      ];
    }
  });

    test("only one error when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email can't be empty");
    });

    test("only one error when null", function() {
      model.populate({ email: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email can't be empty");
    });

    test("only one error when blank", function() {
      model.populate({ email: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], "Email can't be empty");
    });

    test("fails when no at signs", function() {
      model.populate({ email: "joe" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Email must be a valid email address');
    });

    test("succeeds with good email", function() {
      model.populate({ email: "joe.blow@foo.com" });
      ok (model.isValid());
      equal (model.errors.length, 0);
    });


})();