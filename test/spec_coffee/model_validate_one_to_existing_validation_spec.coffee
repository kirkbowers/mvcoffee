MVCoffee = require("../lib/mvcoffee")

# NS1ev = {}

theModel = class User1ev extends MVCoffee.Model
  fields: [
    name: "quantity"
    validates: { test: "presence" }
  ]

theModel.validates "quantity",
  test: "numericality"
  allow_blank: true
  greater_than:
    value: 0
    message: "must be freakin' positive, yo"

describe "the validates macro adds a validation to a field declared statically with an existing validation", ->
  it "should create a new quantity property on fields list", ->
    user = new User1ev()
    expect(user.fields.length).toBe(1)
    expect(user.fields[0].name).toBe("quantity")
    expect(user.fields[0].validates instanceof Array).toBeTruthy()
    expect(user.fields[0].validates.length).toBe(2)
  
  it "should still validate presence of the quantity property", ->
    user = new User1ev(quantity: "")
    expect(user.errors.length).toBe(1)

  it "should validate numericality of the quantity property", ->
    user = new User1ev(quantity: -1)
    expect(user.errors.length).toBe(1)
    expect(user.errors[0]).toBe("Quantity must be freakin' positive, yo")
