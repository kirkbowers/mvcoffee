(function() {
  var model;
  
  module("custom validator", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'custom' }
        }
      ];
      
      model.custom = function(val) {
        // Test that val is one of three possible valid values
        return (val === "valid" ||
          val === "kosher" ||
          val === "the dude abides");
      }
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

    test("fails when not one of the three acceptable values", function() {
      model.populate({ my_field: "unacceptable" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("passes when valid", function() {
      model.populate({ my_field: "valid" });
      ok (model.isValid());
    });

    test("passes when kosher", function() {
      model.populate({ my_field: "kosher" });
      ok (model.isValid());
    });

    test("passes when the dude abides", function() {
      model.populate({ my_field: "the dude abides" });
      ok (model.isValid());
    });
    
  // The above set of tests pretty much prove it works as intended, but I added this
  // set just as a sanity check since I use the modByThree as an example in the 
  // README docs.
  module("custom validator working with a number", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'modByThree' }
        }
      ];
      
      model.modByThree = function(val) {
        return parseFloat(val) % 3 === 0;
      }
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

    test("fails when not a number", function() {
      model.populate({ my_field: "unacceptable" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("fails when a float", function() {
      model.populate({ my_field: "3.1" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("fails when an int not divis by 3", function() {
      model.populate({ my_field: "5" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is invalid');
    });

    test("passes when 3", function() {
      model.populate({ my_field: "3" });
      ok (model.isValid());
    });

    test("passes when 81", function() {
      model.populate({ my_field: "81" });
      ok (model.isValid());
    });


  module("non-existent custom validator", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'custom_typo' }
        }
      ];
      
      model.custom = function(val) {
        // Test that val is one of three possible valid values
        return (val === "valid" ||
          val === "kosher" ||
          val === "the dude abides");
      }
    }
  });

    test("fails with any input", function() {
      throws(
        function() {
          model.populate({ my_field: "valid" })
        },
        /custom validation is not a function/
      );
    });
    

})();