MVCoffee = require("../lib/mvcoffee")

theModel = class PresenceModel extends MVCoffee.Model
  canSkip: ->
    @skip

theModel.validates 'present', test: 'presence'
theModel.validates 'present_with_message',
  test: 'presence'
  message: 'must have a custom message'
theModel.validates 'present_with_display', test: 'presence'
theModel.displays 'present_with_display', 'Display Name'
theModel.validates 'present_with_unless', test: 'presence', unless: 'canSkip'
  
  

describe "presence", ->
  model = null
  
  beforeEach ->
    model = new PresenceModel
      present: 'a'
      present_with_display: 'b'
      present_with_message: 'c'
      present_with_unless: 'd'

  
  it "validates with all present", ->
    expect( model.isValid() ).toBeTruthy()
  
  it "fails with present null", ->
    model.present = null;
    model.validate();
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Present can't be empty")
  
  it "fails with present blank", ->
    model.present = '';
    model.validate();
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Present can't be empty")
  
  it "fails with present with display null", ->
    model.present_with_display = null;
    model.validate();
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Display Name can't be empty")
  
  it "fails with present with message null", ->
    model.present_with_message = null;
    model.validate();
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Present with message must have a custom message")
  
  it "fails with present with unless null and function false", ->
    model.skip = false
    model.present_with_unless = null;
    model.validate();
    expect( ! model.isValid() ).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Present with unless can't be empty")
  
  it "ok with present with unless present and function true", ->
    model.skip = true;
    model.validate();
    expect( model.isValid() ).toBeTruthy()
  
  it "ok with present with unless null and function true", ->
    model.present_with_unless = null;
    model.skip = true;
    model.validate();
    expect( model.isValid() ).toBeTruthy()
  
