MVCoffee = require("../lib/mvcoffee")

theModel = class ErrorsForFieldModel extends MVCoffee.Model
  modByThree: (val) ->
    parseFloat(val) % 3 is 0

theModel.validates 'a', test: 'presence'
theModel.validates 'b', 
  test: 'presence'
  message: 'must have a custom message'
theModel.validates 'c', test: 'presence'
theModel.displays 'c', 'Display Name'
theModel.validates 'd',
  test: 'numericality'
  greater_than: 3
theModel.validates 'd',
  test: 'modByThree'
  message: 'must be divisible by 3'  
  
  

describe "errors for field", ->
  model = null
  
  beforeEach ->
    model = new ErrorsForFieldModel
      a: 'a'
      b: 'b'
      c: 'c'
      d: 6
  
  it "has all falsey when the model is valid", ->
    expect( model.isValid() ).toBeTruthy()
    expect( model.errorsForField["a"] ).toBeFalsy()
    expect( model.errorsForField["b"] ).toBeFalsy()
    expect( model.errorsForField["c"] ).toBeFalsy()
    expect( model.errorsForField["d"] ).toBeFalsy()
      
  it "has standard message for an invalid field", ->
    model.a = null;
    model.validate();
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("A can't be empty")
    expect( model.errorsForField["a"] ).toBeTruthy()
    expect( model.errorsForField["a"].length ).toEqual(1)
    expect(model.errorsForField["a"][0]).toEqual("A can't be empty")
    expect( model.errorsForField["b"] ).toBeFalsy()
    expect( model.errorsForField["c"] ).toBeFalsy()
    expect( model.errorsForField["d"] ).toBeFalsy()
      
  it "has custom message for an invalid field", ->
    model.b = null;
    model.validate();
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("B must have a custom message")
    expect( model.errorsForField["a"] ).toBeFalsy()
    expect( model.errorsForField["b"] ).toBeTruthy()
    expect( model.errorsForField["b"].length ).toEqual(1)
    expect(model.errorsForField["b"][0]).toEqual("B must have a custom message")
    expect( model.errorsForField["c"] ).toBeFalsy()
    expect( model.errorsForField["d"] ).toBeFalsy()
      
  it "has a message for an invalid field with a custom display", ->
    model.c = null;
    model.validate();
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Display Name can't be empty")
    expect( model.errorsForField["a"] ).toBeFalsy()
    expect( model.errorsForField["b"] ).toBeFalsy()
    expect( model.errorsForField["c"] ).toBeTruthy()
    expect( model.errorsForField["c"].length ).toEqual(1)
    expect(model.errorsForField["c"][0]).toEqual("Display Name can't be empty")
    expect( model.errorsForField["d"] ).toBeFalsy()
  
  it "has messages for two invalid fields", ->
    model.a = null
    model.b = null
    model.validate()
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(2)
    expect(model.errors[0]).toEqual("A can't be empty")
    expect(model.errors[1]).toEqual("B must have a custom message")
    expect( model.errorsForField["a"] ).toBeTruthy()
    expect( model.errorsForField["a"].length ).toEqual(1)
    expect(model.errorsForField["a"][0]).toEqual("A can't be empty")
    expect( model.errorsForField["b"] ).toBeTruthy()
    expect( model.errorsForField["b"].length ).toEqual(1)
    expect(model.errorsForField["b"][0]).toEqual("B must have a custom message")
    expect( model.errorsForField["c"] ).toBeFalsy()
    expect( model.errorsForField["d"] ).toBeFalsy()
  
  it "has two messages a field with two errors", ->
    model.d = 2
    model.validate()
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(2)
    expect(model.errors[0]).toEqual("D must be greater than 3")
    expect(model.errors[1]).toEqual("D must be divisible by 3")
    expect( model.errorsForField["a"] ).toBeFalsy()
    expect( model.errorsForField["b"] ).toBeFalsy()
    expect( model.errorsForField["c"] ).toBeFalsy()
    expect( model.errorsForField["d"] ).toBeTruthy()
    expect( model.errorsForField["d"].length ).toEqual(2)
    expect(model.errorsForField["d"][0]).toEqual("D must be greater than 3")
    expect(model.errorsForField["d"][1]).toEqual("D must be divisible by 3")
  
  