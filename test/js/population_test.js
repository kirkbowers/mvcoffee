jQuery(document).ready(function() {
  var model;
  
  module("population from object literal at construction with only pre-defined fields", {
    setup: function() {
      model = new PopulationModel({
        city: 'Orlando',
        description: 'Lots of theme parks',
        population: 249562,
        has_great_brewpubs: false,
        is_warm_in_winter: true
      });
    }
  });

    test("model is valid", function() {
      // This should work with the number coming as an actual number literal
      ok (model.isValid());
    });

    test("city is populated", function() {
      equal (model.city, "Orlando");
    });

    test("description is populated", function() {
      equal (model.description, "Lots of theme parks");
    });

    test("population is populated", function() {
      equal (model.population, 249562);
    });

    test("first boolean is populated", function() {
      equal (model.has_great_brewpubs, false);
    });

    test("second boolean is populated", function() {
      equal (model.is_warm_in_winter, true);
    });

  module("population from object literal at construction with an extra field", {
    setup: function() {
      model = new PopulationModel({
        city: 'Orlando',
        description: 'Lots of theme parks',
        population: 249562,
        has_great_brewpubs: false,
        is_warm_in_winter: true,
        id: 3
      });
    }
  });

    test("model is valid", function() {
      // This should work with the number coming as an actual number literal
      // And the extra "id" field that is not defined in the model meta-data
      ok (model.isValid());
    });

    test("city is populated", function() {
      equal (model.city, "Orlando");
    });

    test("description is populated", function() {
      equal (model.description, "Lots of theme parks");
    });

    test("population is populated", function() {
      equal (model.population, 249562);
    });

    test("first boolean is populated", function() {
      equal (model.has_great_brewpubs, false);
    });

    test("second boolean is populated", function() {
      equal (model.is_warm_in_winter, true);
    });

    test("extra field is populated", function() {
      equal (model.id, 3);
    });

  module("population from JSON at construction with an extra field", {
    setup: function() {
      var json = '{"id":3,"city":"Orlando","description":"Lots of theme parks","population":249562,"has_great_brewpubs":false,"is_warm_in_winter":true}';
      
      model = new PopulationModel(JSON.parse(json));
    }
  });

    test("model is valid", function() {
      ok (model.isValid());
    });

    test("city is populated", function() {
      equal (model.city, "Orlando");
    });

    test("description is populated", function() {
      equal (model.description, "Lots of theme parks");
    });

    test("population is populated", function() {
      equal (model.population, 249562);
    });

    test("first boolean is populated", function() {
      equal (model.has_great_brewpubs, false);
    });

    test("second boolean is populated", function() {
      equal (model.is_warm_in_winter, true);
    });

    test("extra field is populated", function() {
      equal (model.id, 3);
    });

  module("population from JSON at construction with an extra field", {
    setup: function() {
      model = new PopulationModel();
      
      // This will populate from the web page.
      model.populate();
    }
  });

    test("model is valid", function() {
      ok (model.isValid());
    });

    test("city is populated", function() {
      equal (model.city, "Portland");
    });

    test("description is populated", function() {
      equal (model.description, "Beautiful in summer, rainy in winter.");
    });

    test("population is populated", function() {
      equal (model.population, 603106);
    });

    test("first boolean is populated", function() {
      equal (model.has_great_brewpubs, true);
    });

    test("second boolean is populated", function() {
      equal (model.is_warm_in_winter, false);
    });

});
