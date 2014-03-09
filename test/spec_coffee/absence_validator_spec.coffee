MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates "my_field", test: "absence"
  
describe "absence", ->
  model = null

  beforeEach ->
    model = new User

  it "passes when undefined", ->
    model.validate()
    expect(model.isValid()).toBeTruthy()

  it "passes when null", ->
    model.populate({ my_field: null })
    expect(model.isValid()).toBeTruthy()

  it "passes when blank", ->
    model.populate({ my_field: "" })
    expect(model.isValid()).toBeTruthy()

  it "passes when only whitespace", ->
    model.populate({ my_field: "   " })
    expect(model.isValid()).toBeTruthy()

  it "fails when contains non-whitespace", ->
    model.populate({ my_field: "a" })
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be blank')
