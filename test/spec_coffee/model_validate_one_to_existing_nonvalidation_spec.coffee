MVCoffee = require("../lib/mvcoffee")

theModel = class User extends MVCoffee.Model
  fields: [
    name: "quantity"
    display: "number of things"
  ]
  
theModel.validates "quantity",
  test: "numericality"
  allow_blank: true
  greater_than:
    value: 0
    message: "must be freakin' positive, yo"
      
describe "the validates macro adds a validation to a field declared statically with no existing validation", ->

  it "should create a new quantity property on fields list", ->
    user = new User()
    expect(user.fields.length).toBe(1)
    expect(user.fields[0].name).toBe("quantity")
  
  it "should validate numericality of the quantity property", ->
    user = new User(quantity: -1)
    expect(user.errors.length).toBe(1)
    expect(user.errors[0]).toBe("number of things must be freakin' positive, yo")

  it "should not modify the parent class's prototype", ->
    expect(MVCoffee.Model.prototype.fields.length).toBe(0)
