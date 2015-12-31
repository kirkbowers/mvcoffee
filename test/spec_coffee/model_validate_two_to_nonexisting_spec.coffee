MVCoffee = require("../lib/mvcoffee")

theModel = class User extends MVCoffee.Model

theModel.validates "quantity", test: "presence"

theModel.validates "quantity",
  test: "numericality"
  allow_blank: true
  greater_than:
    value: 0
    message: "must be freakin' positive, yo"
      

describe "the validates macro method adds a validation to an existing field", ->
  it "should create a new quantity property on fields list", ->
    user = new User()
    expect(user.fields.length).toBe(1)
    expect(user.fields[0].name).toBe("quantity")
    expect(user.fields[0].validates instanceof Array).toBeTruthy()
    expect(user.fields[0].validates.length).toBe(2)
  
  it "should still validate presence of the quantity property", ->
    user = new User(quantity: "")
    user.validate()
    expect(user.errors.length).toBe(1)

  it "should validate numericality of the quantity property", ->
    user = new User(quantity: -1)
    user.validate()
    expect(user.errors.length).toBe(1)
    expect(user.errors[0]).toBe("Quantity must be freakin' positive, yo")

  it "should not modify the parent class's prototype", ->
    expect(MVCoffee.Model.prototype.fields.length).toBe(0)

