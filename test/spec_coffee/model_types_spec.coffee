MVCoffee = require("../lib/mvcoffee")


theModel = class User extends MVCoffee.Model

theModel.types "is_silly", "boolean"

describe "the types macro method adds typing to a new field", ->

  it "should create a new is_silly property on fields list", ->
    user = new User()
    expect(user.fields.length).toBe(1)
    expect(user.fields[0].name).toBe("is_silly")
    expect(user.fields[0].type).toBe("boolean")

  it "should not modify the parent class's prototype", ->
    expect(MVCoffee.Model.prototype.fields.length).toBe(0)

