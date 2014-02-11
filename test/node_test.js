#!/usr/bin/env nodeunit

/*
 * This is a very simple test just for the purposes of making sure the mvcoffee lib
 * can be required into node and the namespacing works correctly.
 * As yet, MVCoffee is not packaged officially as a node module, since it is intended
 * for client side use, but this isn't a bad sanity check to have anyway.
 */

var MVCoffee = require("../../mvcoffee");

var model = new MVCoffee.Model();

model.fields = [
  {
    name: 'number',
    validates: { test: 'numericality' }
  }
];

exports.testSuccessfulValidation = function(test) {
  model.populate({ number: "42" });
  test.ok(model.isValid());
  test.done();
}

exports.testFailedValidation = function(test) {
  model.populate({ number: "foo" });
  test.expect(3);
  test.ok(! model.isValid());
  test.equal(model.errors.length, 1);
  test.equal(model.errors[0], "Number must be a number");
  test.done();
}

