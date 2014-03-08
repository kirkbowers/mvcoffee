MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates "my_field", test: 'format', with: /^[a-zA-Z]+$/
  
describe "format", ->
  model = null
  
  beforeEach ->
    model = new User

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when letters and numbers", ->
    model.populate({ my_field: "abc123" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when letters and punctuation", ->
    model.populate({ my_field: "Stop!" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when letters and whitespace", ->
    model.populate({ my_field: "   island   " });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "passes when only letters", ->
    model.populate({ my_field: "Fluffy" });
    expect(model.isValid()).toBeTruthy()


# Make sure it doesn't bomb if the client forgot to supply an "with" regexp.
# Everything should pass except null and undefined

theUser = class UserWithNoWith extends MVCoffee.Model

theUser.validates "my_field", test: 'format'

describe "format with no 'with' regexp provided", ->
  model = null
  
  beforeEach ->
    model = new UserWithNoWith


  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "passes when blank", ->
    model.populate({ my_field: "" });
    expect(model.isValid()).toBeTruthy()

  it "passes when letters and numbers", ->
    model.populate({ my_field: "abc123" });
    expect(model.isValid()).toBeTruthy()

  it "passes when letters and punctuation", ->
    model.populate({ my_field: "Stop!" });
    expect(model.isValid()).toBeTruthy()

  it "passes when letters and whitespace", ->
    model.populate({ my_field: "   island   " });
    expect(model.isValid()).toBeTruthy()

  it "passes when only letters", ->
    model.populate({ my_field: "Fluffy" });
    expect(model.isValid()).toBeTruthy()

