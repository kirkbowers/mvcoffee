(function() {
  var model;
  
  module("absence", {
    setup: function() {
      model = new MVCoffee.Model();
      model.fields = [
        {
          name: 'my_field',
          validates:
            { test: 'absence' }
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

    test("passes when only whitespace", function() {
      model.populate({ my_field: "   " });
      ok (model.isValid());
    });

    test("fails when contains non-whitespace", function() {
      model.populate({ my_field: "a" });
      ok (! model.isValid());
      equal (model.errors.length, 1);
      equal (model.errors[0], 'My field must be blank');
    });

})();