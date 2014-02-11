(function() {
  var model;
  
  module("float number", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality' }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when null", function() {
      model.populate({ number: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when blank", function() {
      model.populate({ number: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when all letters", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("passes when zero", function() {
      model.populate({ number: "0" });
      ok (model.isValid());
    });
    
    test("passes when a positive integer", function() {
      model.populate({ number: "42" });
      ok (model.isValid());
    });
    
    test("passes when a negative integer", function() {
      model.populate({ number: "-34" });
      ok (model.isValid());
    });
    
    test("passes when a float", function() {
      model.populate({ number: "3.14159" });
      ok (model.isValid());
    });
        
    test("passes when a float in scientific notation", function() {
      model.populate({ number: "2.99e8" });
      ok (model.isValid());
    });
        
    test("fail with a float with leading spaces", function() {
      model.populate({ number: "  3.14159" });
      ok (! model.isValid());
    });
        
    test("fail with a float with trailing spaces", function() {
      model.populate({ number: "3.14159    " });
      ok (! model.isValid());
    });
        
    test("fail with a float with trailing non-numbers", function() {
      model.populate({ number: "3.14159a" });
      ok (! model.isValid());
    });


  module("integer number", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality', only_integer: true }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be an integer');
    });
    
    test("fails when null", function() {
      model.populate({ number: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be an integer');
    });
    
    test("fails when blank", function() {
      model.populate({ number: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be an integer');
    });
    
    test("fails when all letters", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be an integer');
    });
    
    test("passes when zero", function() {
      model.populate({ number: "0" });
      ok (model.isValid());
    });
    
    test("passes when a positive integer", function() {
      model.populate({ number: "42" });
      ok (model.isValid());
    });
    
    test("passes when a negative integer", function() {
      model.populate({ number: "-34" });
      ok (model.isValid());
    });
    
    test("fails when a float", function() {
      model.populate({ number: "3.14159" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be an integer');
    });
        
    test("fail with an int with leading spaces", function() {
      model.populate({ number: "  3" });
      ok (! model.isValid());
    });
        
    test("fail with an int with trailing spaces", function() {
      model.populate({ number: "3  " });
      ok (! model.isValid());
    });
        
    test("fail with an int with trailing non-numbers", function() {
      model.populate({ number: "3a" });
      ok (! model.isValid());
    });


  //==============================================================================

  module("greater than", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality', greater_than: 11 }
        }
      ];
    }
  });

    test("doesn't test > when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be greater than 11');
    });
    
    test("fails when equal to 11", function() {
      model.populate({ number: "11" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be greater than 11');
    });
    
    test("passes when greater than 11", function() {
      model.populate({ number: "11.5" });
      ok (model.isValid());
    });
    
  // Test subvalidation stuff
  module("greater than with subvalidation message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            message: 'has a custom number message',
            greater_than: {
              value: 11,
              message: "has a custom greater than message" 
            }
          }
        }
      ];
    }
  });

    test("doesn't test > when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom number message');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom greater than message');
    });
    
    test("fails when equal to 11", function() {
      model.populate({ number: "11" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom greater than message');
    });
    
    test("passes when greater than 11", function() {
      model.populate({ number: "11.5" });
      ok (model.isValid());
    });
    
  module("greater than with subvalidation only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            greater_than: {
              value: 11,
              only_if: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = true;
    }
  });

    test("runs test when fluffy and fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be greater than 11');
    });
    
    test("doesn't run test when not fluffy and less than 11", function() {
      model.fluffy = false;
      model.populate({ number: "10.9" });
      ok (model.isValid());
    });
    

  module("greater than with subvalidation unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            greater_than: {
              value: 11,
              unless: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = false;
    }
  });

    test("runs test when not fluffy and fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be greater than 11');
    });
    
    test("doesn't run test when fluffy and less than 11", function() {
      model.fluffy = true;
      model.populate({ number: "10.9" });
      ok (model.isValid());
    });
    
  //==============================================================================
  
  module("greater than or equal to", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality', greater_than_or_equal_to: 11 }
        }
      ];
    }
  });

    test("doesn't test >= when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be greater than or equal to 11');
    });
        
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });
    
    test("passes when greater than 11", function() {
      model.populate({ number: "11.5" });
      ok (model.isValid());
    });
    
  // Test subvalidation stuff
  module("greater than or equal with subvalidation message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            message: 'has a custom number message',
            greater_than_or_equal_to: {
              value: 11,
              message: "has a custom greater than or equal message" 
            }
          }
        }
      ];
    }
  });

    test("doesn't test > when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom number message');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom greater than or equal message');
    });
    
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });
    
    test("passes when greater than 11", function() {
      model.populate({ number: "11.5" });
      ok (model.isValid());
    });
    
  module("greater than or equal with subvalidation only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            greater_than_or_equal_to: {
              value: 11,
              only_if: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = true;
    }
  });

    test("runs test when fluffy and fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be greater than or equal to 11');
    });
    
    test("doesn't run test when not fluffy and less than 11", function() {
      model.fluffy = false;
      model.populate({ number: "10.9" });
      ok (model.isValid());
    });
    

  module("greater than or equal with subvalidation unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            greater_than_or_equal_to: {
              value: 11,
              unless: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = false;
    }
  });

    test("runs test when not fluffy and fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be greater than or equal to 11');
    });
    
    test("doesn't run test when fluffy and less than 11", function() {
      model.fluffy = true;
      model.populate({ number: "10.9" });
      ok (model.isValid());
    });
    

    
  //==============================================================================
  
  module("equal to", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality', equal_to: 11 }
        }
      ];
    }
  });

    test("doesn't test != when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be equal to 11');
    });
        
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });
    
    test("fails when greater than 11", function() {
      model.populate({ number: "11.5" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be equal to 11');
    });
    
  // Test subvalidation stuff
  module("equal with subvalidation message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            message: 'has a custom number message',
            equal_to: {
              value: 11,
              message: "has a custom equal to message" 
            }
          }
        }
      ];
    }
  });

    test("doesn't test != when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom number message');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom equal to message');
    });
    
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });
    
  module("equal to with subvalidation only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            equal_to: {
              value: 11,
              only_if: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = true;
    }
  });

    test("runs test when fluffy and fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be equal to 11');
    });
    
    test("doesn't run test when not fluffy and less than 11", function() {
      model.fluffy = false;
      model.populate({ number: "10.9" });
      ok (model.isValid());
    });
    

  module("equal to with subvalidation unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            equal_to: {
              value: 11,
              unless: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = false;
    }
  });

    test("runs test when not fluffy and fails when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be equal to 11');
    });
    
    test("doesn't run test when fluffy and less than 11", function() {
      model.fluffy = true;
      model.populate({ number: "10.9" });
      ok (model.isValid());
    });
    

  //==============================================================================

  module("less than", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality', less_than: 11 }
        }
      ];
    }
  });

    test("doesn't test < when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when greater than 11", function() {
      model.populate({ number: "11.1" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be less than 11');
    });
    
    test("fails when equal to 11", function() {
      model.populate({ number: "11" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be less than 11');
    });
    
    test("passes when less than 11", function() {
      model.populate({ number: "10.9" });
      ok (model.isValid());
    });
    
  // Test subvalidation stuff
  module("less than with subvalidation message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            message: 'has a custom number message',
            less_than: {
              value: 11,
              message: "has a custom less than message" 
            }
          }
        }
      ];
    }
  });

    test("doesn't test < when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom number message');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "11.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom less than message');
    });
    
    test("fails when equal to 11", function() {
      model.populate({ number: "11" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom less than message');
    });
    
    test("passes when less than 11", function() {
      model.populate({ number: "10.5" });
      ok (model.isValid());
    });
    
  module("less than with subvalidation only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            less_than: {
              value: 11,
              only_if: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = true;
    }
  });

    test("runs test when fluffy and fails when less than 11", function() {
      model.populate({ number: "11.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be less than 11');
    });
    
    test("doesn't run test when not fluffy and less than 11", function() {
      model.fluffy = false;
      model.populate({ number: "11.9" });
      ok (model.isValid());
    });
    

  module("less than with subvalidation unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            less_than: {
              value: 11,
              unless: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = false;
    }
  });

    test("runs test when not fluffy and fails when less than 11", function() {
      model.populate({ number: "11.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be less than 11');
    });
    
    test("doesn't run test when fluffy and less than 11", function() {
      model.fluffy = true;
      model.populate({ number: "11.9" });
      ok (model.isValid());
    });
    
  //==============================================================================
  
  module("less than or equal to", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality', less_than_or_equal_to: 11 }
        }
      ];
    }
  });

    test("doesn't test <= when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "11.1" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be less than or equal to 11');
    });
        
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });
    
    test("passes when less than 11", function() {
      model.populate({ number: "10.5" });
      ok (model.isValid());
    });
    
  // Test subvalidation stuff
  module("less than or equal with subvalidation message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            message: 'has a custom number message',
            less_than_or_equal_to: {
              value: 11,
              message: "has a custom less than or equal message" 
            }
          }
        }
      ];
    }
  });

    test("doesn't test <= when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom number message');
    });
    
    test("fails when less than 11", function() {
      model.populate({ number: "11.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom less than or equal message');
    });
    
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });
    
    test("passes when less than 11", function() {
      model.populate({ number: "10.5" });
      ok (model.isValid());
    });
    
  module("less than or equal with subvalidation only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            less_than_or_equal_to: {
              value: 11,
              only_if: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = true;
    }
  });

    test("runs test when fluffy and fails when less than 11", function() {
      model.populate({ number: "11.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be less than or equal to 11');
    });
    
    test("doesn't run test when not fluffy and less than 11", function() {
      model.fluffy = false;
      model.populate({ number: "11.9" });
      ok (model.isValid());
    });
    

  module("less than or equal with subvalidation unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            less_than_or_equal_to: {
              value: 11,
              unless: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = false;
    }
  });

    test("runs test when not fluffy and fails when less than 11", function() {
      model.populate({ number: "11.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be less than or equal to 11');
    });
    
    test("doesn't run test when fluffy and less than 11", function() {
      model.fluffy = true;
      model.populate({ number: "11.9" });
      ok (model.isValid());
    });
    

  //==============================================================================
  
  module("odd", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality', odd: true }
        }
      ];
    }
  });

    test("doesn't test odd when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when not an integer", function() {
      model.populate({ number: "11.1" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be odd');
    });
        
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });
    
    test("fails when even", function() {
      model.populate({ number: "10" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be odd');
    });
    
  // Test subvalidation stuff
  module("odd with subvalidation message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            message: 'has a custom number message',
            odd: {
              message: "has a custom odd message" 
            }
          }
        }
      ];
    }
  });

    test("doesn't test odd when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom number message');
    });
    
    test("fails when not an integer", function() {
      model.populate({ number: "11.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom odd message');
    });
    
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });
    
    test("fails when even", function() {
      model.populate({ number: "10" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom odd message');
    });
    
  module("odd with subvalidation only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            odd: {
              only_if: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = true;
    }
  });

    test("runs test when fluffy and fails when even", function() {
      model.populate({ number: "-4" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be odd');
    });
    
    test("doesn't run test when not fluffy and even", function() {
      model.fluffy = false;
      model.populate({ number: "2" });
      ok (model.isValid());
    });
    

  module("odd with subvalidation unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            odd: {
              unless: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = false;
    }
  });

    test("runs test when not fluffy and fails when even", function() {
      model.populate({ number: "4" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be odd');
    });
    
    test("doesn't run test when fluffy and even", function() {
      model.fluffy = true;
      model.populate({ number: "4" });
      ok (model.isValid());
    });
    

    

  //==============================================================================
  
  module("even", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { test: 'numericality', even: true }
        }
      ];
    }
  });

    test("doesn't test even when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be a number');
    });
    
    test("fails when not an integer", function() {
      model.populate({ number: "10.1" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be even');
    });
        
    test("passes when equal to 10", function() {
      model.populate({ number: "10" });
      ok (model.isValid());
    });
    
    test("passes when equal to -10", function() {
      model.populate({ number: "-10" });
      ok (model.isValid());
    });
    
    test("passes when equal to 0", function() {
      model.populate({ number: "0" });
      ok (model.isValid());
    });
    
    test("fails when odd", function() {
      model.populate({ number: "11" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be even');
    });
    
  // Test subvalidation stuff
  module("even with subvalidation message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            message: 'has a custom number message',
            even: {
              message: "has a custom even message" 
            }
          }
        }
      ];
    }
  });

    test("doesn't test even when not a number", function() {
      model.populate({ number: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom number message');
    });
    
    test("fails when not an integer", function() {
      model.populate({ number: "11.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom even message');
    });
    
    test("passes when equal to 10", function() {
      model.populate({ number: "10" });
      ok (model.isValid());
    });
    
    test("fails when odd", function() {
      model.populate({ number: "11" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number has a custom even message');
    });
    
  module("even with subvalidation only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            even: {
              only_if: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = true;
    }
  });

    test("runs test when fluffy and fails when odd", function() {
      model.populate({ number: "-11" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be even');
    });
    
    test("doesn't run test when not fluffy and odd", function() {
      model.fluffy = false;
      model.populate({ number: "3" });
      ok (model.isValid());
    });
    

  module("even with subvalidation unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality', 
            even: {
              unless: "isFluffy"
            }
          }
        }
      ];
      
      model.isFluffy = function() {
        return this.fluffy;
      }
        
      model.fluffy = false;
    }
  });

    test("runs test when not fluffy and fails when odd", function() {
      model.populate({ number: "5" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be even');
    });
    
    test("doesn't run test when fluffy and odd", function() {
      model.fluffy = true;
      model.populate({ number: "5" });
      ok (model.isValid());
    });
    

  //================================================================================
  //================================================================================
    
  module("number in a range", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'number',
          validates: { 
            test: 'numericality',
            greater_than_or_equal_to: 5, 
            less_than_or_equal_to: 11 
          }
        }
      ];
    }
  });

    test("fails when less than bottom of range", function() {
      model.populate({ number: "4.9" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be greater than or equal to 5');
    });
    
    test("passes when equal to 5", function() {
      model.populate({ number: "5" });
      ok (model.isValid());
    });
    
    test("passes when equal to 7.9", function() {
      model.populate({ number: "7.9" });
      ok (model.isValid());
    });
    
    test("passes when equal to 11", function() {
      model.populate({ number: "11" });
      ok (model.isValid());
    });

    test("fails when greater than top of range", function() {
      model.populate({ number: "11.1" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'Number must be less than or equal to 11');
    });
    





})();
