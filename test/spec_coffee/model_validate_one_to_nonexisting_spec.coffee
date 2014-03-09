MVCoffee = require("../lib/mvcoffee")

theModel = class User extends MVCoffee.Model

theModel.validates "quantity", test: "presence"

describe "the validates macro method adds a validation to a new field", ->

  it "should create a new quantity property on fields list", ->
    user = new User()
    expect(user.fields.length).toBe(1)
    expect(user.fields[0].name).toBe("quantity")

  it "should validate presence of the quantity property", ->
    user = new User(quantity: "")
    expect(user.errors.length).toBe(1)

  it "should not modify the parent class's prototype", ->
    expect(MVCoffee.Model.prototype.fields.length).toBe(0)
    

