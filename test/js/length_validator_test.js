(function() {
  var model;
  
  module("length minimum, default message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'length', minimum: 3 }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("passes when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (model.isValid());
    });

    test("passes when really long", function() {
      model.populate({ my_field: "This is a really long string" });
      ok (model.isValid());
    });

  module("length minimum, custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              minimum: { value: 3, message: "must be at least 3 characters"}
            }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 characters');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 characters');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 characters');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 characters');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 characters');
    });

    test("passes when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (model.isValid());
    });

    test("passes when really long", function() {
      model.populate({ my_field: "This is a really long string" });
      ok (model.isValid());
    });



  module("length minimum, custom tokenizer", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              tokenizer: function(val) {
                return val.split(/\s+/);
              },
              minimum: { 
                value: 3, 
                message: "must be at least 3 words"
              }
            }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when two words long", function() {
      model.populate({ my_field: "Two words" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("passes when three words long", function() {
      model.populate({ my_field: "Three words long" });
      ok (model.isValid());
    });
    
    test("passes when three words long with extra spaces", function() {
      model.populate({ my_field: "Three     words   long" });
      ok (model.isValid());
    });

    test("passes when really long", function() {
      model.populate({ my_field: "This is a really long string, I mean it is really long!" });
      ok (model.isValid());
    });

  module("length minimum with only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              minimum: { 
                value: 3, 
                only_if: "shouldDoIt"
              }
            }
        }
      ];
      
      model.shouldDoIt = function() {
        return this.do_it;
      }
    }
  });

    test("fails when two chars long and do it is true", function() {
      model.do_it = true;
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("passes when two chars long and do it is false", function() {
      model.do_it = false;
      model.populate({ my_field: "ab" });
      ok (model.isValid());
    });

  module("length minimum with unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              minimum: { 
                value: 3, 
                unless: "shouldntDoIt"
              }
            }
        }
      ];
      
      model.shouldntDoIt = function() {
        return this.do_it;
      }
    }
  });

    test("fails when two chars long and do it is false", function() {
      model.do_it = false;
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("passes when two chars long and do it is true", function() {
      model.do_it = true;
      model.populate({ my_field: "ab" });
      ok (model.isValid());
    });


  //=================================================================================
  // maximum
  //
  // Note: even without allow_blank, nulls and blanks pass since a zero length string 
  // is in fact less than the maximum number of characters.
  // The typical use case, if you want to enforce at least a 1 token length is to 
  // either pair maximum with minimum, or to use a separate "presence" test.
  
    module("length maximum, default message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates: { test: 'length', maximum: 10 }
        }
      ];
    }
  });

    test("passes when undefined", function() {
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

    test("passes when one char long", function() {
      model.populate({ my_field: "a" });
      ok (model.isValid());
    });

    test("passes when ten chars long", function() {
      model.populate({ my_field: "abcdefghij" });
      ok (model.isValid());
    });

    test("fails when eleven chars long", function() {
      model.populate({ my_field: "abcdefghijl" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too long (maximum is 10 characters)');
    });

    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too long (maximum is 10 characters)');
    });

  module("length maximum, custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              maximum: { value: 10, message: "must be at most 10 characters"}
            }
        }
      ];
    }
  });


    test("passes when undefined", function() {
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

    test("passes when one char long", function() {
      model.populate({ my_field: "a" });
      ok (model.isValid());
    });

    test("passes when ten chars long", function() {
      model.populate({ my_field: "abcdefghij" });
      ok (model.isValid());
    });

    test("fails when eleven chars long", function() {
      model.populate({ my_field: "abcdefghijl" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at most 10 characters');
    });

    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at most 10 characters');
    });


  module("length maximum, custom tokenizer", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              tokenizer: function(val) {
                return val.split(/\s+/);
              },
              maximum: { 
                value: 10, 
                message: "must be at most 10 words"
              }
            }
        }
      ];
    }
  });

    test("passes when undefined", function() {
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

    test("passes when one char long", function() {
      model.populate({ my_field: "a" });
      ok (model.isValid());
    });

    test("passes when ten chars long", function() {
      model.populate({ my_field: "abcdefghij" });
      ok (model.isValid());
    });

    test("passes when eleven chars long", function() {
      model.populate({ my_field: "abcdefghijl" });
      ok (model.isValid());
    });

    test("passes when three words long with extra spaces", function() {
      model.populate({ my_field: "Three     words   long" });
      ok (model.isValid());
    });

    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string, I mean it is really long!" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at most 10 words');
    });


  module("length maximum with only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              maximum: { 
                value: 10, 
                only_if: "shouldDoIt"
              }
            }
        }
      ];
      
      model.shouldDoIt = function() {
        return this.do_it;
      }
    }
  });

    test("fails when eleven chars long and do it is true", function() {
      model.do_it = true;
      model.populate({ my_field: "abcdefghijkl" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too long (maximum is 10 characters)');
    });

    test("passes when eleven chars long and do it is false", function() {
      model.do_it = false;
      model.populate({ my_field: "abcdefghijkl" });
      ok (model.isValid());
    });

  module("length maximum with unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              maximum: { 
                value: 10, 
                unless: "shouldntDoIt"
              }
            }
        }
      ];
      
      model.shouldntDoIt = function() {
        return this.do_it;
      }
    }
  });

    test("fails when eleven chars long and do it is false", function() {
      model.do_it = false;
      model.populate({ my_field: "abcdefghijkl" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too long (maximum is 10 characters)');
    });

    test("passes when eleven chars long and do it is true", function() {
      model.do_it = true;
      model.populate({ my_field: "abcdefghijkl" });
      ok (model.isValid());
    });

  //=================================================================================
  // is

  module("length is, default message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'length', is: 3 }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

    test("passes when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (model.isValid());
    });

    test("fails when four chars long", function() {
      model.populate({ my_field: "abcd" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

  module("length is, custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              is: { value: 3, message: "must be exactly 3 characters"}
            }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 characters');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 characters');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 characters');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 characters');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 characters');
    });

    test("passes when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (model.isValid());
    });

    test("fails when four chars long", function() {
      model.populate({ my_field: "abcd" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 characters');
    });

    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 characters');
    });



  module("length is, custom tokenizer", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              tokenizer: function(val) {
                return val.split(/\s+/);
              },
              is: { 
                value: 3, 
                message: "must be exactly 3 words"
              }
            }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

    test("fails when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

    test("fails when two words long", function() {
      model.populate({ my_field: "Two words" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

    test("passes when three words long", function() {
      model.populate({ my_field: "Three words long" });
      ok (model.isValid());
    });
    
    test("fails when four words long", function() {
      model.populate({ my_field: "Four stinkin' words long" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

    test("passes when three words long with extra spaces", function() {
      model.populate({ my_field: "Three     words   long" });
      ok (model.isValid());
    });

    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string, I mean it is really long!" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be exactly 3 words');
    });

  module("length is with only_if", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              is: { 
                value: 3, 
                only_if: "shouldDoIt"
              }
            }
        }
      ];
      
      model.shouldDoIt = function() {
        return this.do_it;
      }
    }
  });

    test("fails when two chars long and do it is true", function() {
      model.do_it = true;
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

    test("passes when two chars long and do it is false", function() {
      model.do_it = false;
      model.populate({ my_field: "ab" });
      ok (model.isValid());
    });

  module("length is with unless", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              is: { 
                value: 3, 
                unless: "shouldntDoIt"
              }
            }
        }
      ];
      
      model.shouldntDoIt = function() {
        return this.do_it;
      }
    }
  });

    test("fails when two chars long and do it is false", function() {
      model.do_it = false;
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is the wrong length (must be 3 characters)');
    });

    test("passes when two chars long and do it is true", function() {
      model.do_it = true;
      model.populate({ my_field: "ab" });
      ok (model.isValid());
    });

  //=================================================================================
  // range, equivalent to "in" or "within" in rails, but we just use minimum and
  // maximum since there isn't a native "range" datatype in javascript.

  module("length range, default message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'length', minimum: 3, maximum: 10 }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too short (minimum is 3 characters)');
    });

    test("passes when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (model.isValid());
    });

    test("passes when seven chars long", function() {
      model.populate({ my_field: "abcdefg" });
      ok (model.isValid());
    });

    test("passes when ten chars long", function() {
      model.populate({ my_field: "abcdefghij" });
      ok (model.isValid());
    });

    test("fails when eleven chars long", function() {
      model.populate({ my_field: "abcdefghijk" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too long (maximum is 10 characters)');
    });

    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field is too long (maximum is 10 characters)');
    });

  module("length range, custom message", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length',
              message: "must be between 3 and 10 characters",
              minimum: 3,
              maximum: 10
            }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be between 3 and 10 characters');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be between 3 and 10 characters');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be between 3 and 10 characters');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be between 3 and 10 characters');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be between 3 and 10 characters');
    });

    test("passes when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (model.isValid());
    });

    test("passes when seven chars long", function() {
      model.populate({ my_field: "abcdefg" });
      ok (model.isValid());
    });

    test("passes when ten chars long", function() {
      model.populate({ my_field: "abcdefghij" });
      ok (model.isValid());
    });

    test("fails when eleven chars long", function() {
      model.populate({ my_field: "abcdefghijk" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be between 3 and 10 characters');
    });

    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be between 3 and 10 characters');
    });


  module("length range, custom tokenizer", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { 
              test: 'length', 
              tokenizer: function(val) {
                return val.split(/\s+/);
              },
              minimum: { 
                value: 3, 
                message: "must be at least 3 words"
              },
              maximum: {
                value: 10,
                message: "must be at most 10 words"
              }
            }
        }
      ];
    }
  });

    test("fails when undefined", function() {
      model.validate();
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when null", function() {
      model.populate({ my_field: null });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when blank", function() {
      model.populate({ my_field: "" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when one char long", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when two chars long", function() {
      model.populate({ my_field: "ab" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when three chars long", function() {
      model.populate({ my_field: "abc" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("fails when two words long", function() {
      model.populate({ my_field: "Two words" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at least 3 words');
    });

    test("passes when three words long", function() {
      model.populate({ my_field: "Three words long" });
      ok (model.isValid());
    });
    
    test("passes when three words long with extra spaces", function() {
      model.populate({ my_field: "Three     words   long" });
      ok (model.isValid());
    });

    test("passes when 10 words long", function() {
      model.populate({ my_field: "One two three four five six seven eight nine ten" });
      ok (model.isValid());
    });
    
    test("fails when really long", function() {
      model.populate({ my_field: "This is a really long string, I mean it is really long!" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be at most 10 words');
    });



})();
