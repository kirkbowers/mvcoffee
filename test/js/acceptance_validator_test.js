(function() {
  var model;
  
  // The idea with the model name "my_field" is that we can exercise the trick to map
  // the field name to a human readable format if the "display" is not suppled.
  module("acceptance, simple case", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'acceptance' }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("fails when 0", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });


    test("passes when 1", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });
    
  //==============================================================================
  // Try with a custom message
  
  module("acceptance, custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'acceptance', message: 'must be complied with' }
        }
      ];
    }
  });

    test("fails when 0", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be complied with');
    });


    test("passes when 1", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });


  //==============================================================================
  // Try with a custom display name
  
  module("acceptance, custom display name", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          display: 'Massive red tape',
          validates: { test: 'acceptance' }
        }
      ];
    }
  });

    test("fails when 0", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Massive red tape must be accepted');
    });


    test("passes when 1", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });

  //==============================================================================
  // Try with a custom display name and custom message
  
  module("acceptance, custom display name", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          display: 'Massive red tape',
          validates: { test: 'acceptance', message: 'must be complied with' }
        }
      ];
    }
  });

    test("fails when 0", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Massive red tape must be complied with');
    });


    test("passes when 1", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });


  //==============================================================================
  // Try with an only_if
  
  module("acceptance, custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'acceptance', only_if: "isFluffy" }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
      
      model.fluffy = true;
    }
  });

    test("fails when 0 and fluffy", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("passes when 1 and fluffy", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });

    test("passes when 0 and not fluffy", function() {
      model.fluffy = false;
      model.populate({ my_field: "0" });
      ok (model.isValid());
    });

  //==============================================================================
  // Try with an unless
  
  module("acceptance, custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'acceptance', unless: "isFluffy" }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
      
      model.fluffy = false;
    }
  });

    test("fails when 0 and not fluffy", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("passes when 1 and not fluffy", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });

    test("passes when 0 and fluffy", function() {
      model.fluffy = true;
      model.populate({ my_field: "0" });
      ok (model.isValid());
    });

  //==============================================================================
  // Try with both an only_if and unless
  
  module("acceptance, custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { 
            test: 'acceptance',
            only_if: "isRotten",
            unless: "isFluffy",
          }
        }
      ];
      
      model.isRotten = function() {
        return this.rotten;
      }
      
      model.isFluffy = function() {
        return this.fluffy;
      }
      
      model.rotten = true;
      model.fluffy = false;
    }
  });

    test("fails when 0, rotten and not fluffy", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("passes when 1, rotten and not fluffy", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });

    test("passes when 0, rotten and fluffy", function() {
      model.fluffy = true;
      model.populate({ my_field: "0" });
      ok (model.isValid());
    });

    test("passes when 0, not rotten and not fluffy", function() {
      model.rotten = false;
      model.populate({ my_field: "0" });
      ok (model.isValid());
    });

    test("passes when 0, not rotten and fluffy", function() {
      model.rotten = false;
      model.fluffy = true;
      model.populate({ my_field: "0" });
      ok (model.isValid());
    });


  //==============================================================================
  // Try with allow_null
  
  module("acceptance, simple case", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'acceptance', allow_null: true }
        }
      ];
    }
  });

    test("passes when undefined", function() {
      model.validate();
      ok (model.isValid());
    });

    test("passes when null", function() {
      model.populate({ my_field: null });
      ok (model.isValid());
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("fails when 0", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });


    test("passes when 1", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });
    
  //==============================================================================
  // Try with allow_blank
  
  module("acceptance, simple case", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'acceptance', allow_blank: true }
        }
      ];
    }
  });

    test("passes when undefined", function() {
      model.validate();
      ok (model.isValid());
    });

    test("passes when null", function() {
      model.populate({ my_field: null });
      ok (model.isValid());
    });

    test("passes when blank", function() {
      model.populate({ my_field: "" });
      ok (model.isValid());
    });

    test("fails when 0", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });


    test("passes when 1", function() {
      model.populate({ my_field: "1" });
      ok (model.isValid());
    });
    
  //==============================================================================
  // Try with custom accept flag
  
  module("acceptance, simple case", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'acceptance', accept: 'yes' }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("fails when 0", function() {
      model.populate({ my_field: "0" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });

    test("fails when 1", function() {
      model.populate({ my_field: "1" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be accepted');
    });


    test("passes when yes", function() {
      model.populate({ my_field: "yes" });
      ok (model.isValid());
    });
    
})();
