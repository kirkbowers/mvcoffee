MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates "my_field", test: 'inclusion', in: ['small', 'medium', 'large'] 
  
# Unlike the sister validator "exclusion", I'm not using allow_blank in the test
# because blank sure as heck is not included in the list.  I still below test the
# usual use case that you'll want to use both inclusion and presence validators
# together to provide more meaningful error messages.
describe "inclusion", ->
  model = null
  
  beforeEach ->
    model = new User

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when null", ->
    model.populate({ email: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when blank", ->
    model.populate({ email: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when extra large", ->
    model.populate({ my_field: "extra large" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "passes when small", ->
    model.populate({ my_field: "small" });
    expect(model.isValid()).toBeTruthy()

  it "passes when medium", ->
    model.populate({ my_field: "medium" });
    expect(model.isValid()).toBeTruthy()

  it "passes when large", ->
    model.populate({ my_field: "large" });
    expect(model.isValid()).toBeTruthy()


theUser = class UserWithPresence extends MVCoffee.Model

theUser.validates "my_field", 
  test: 'inclusion'
  in: ['small', 'medium', 'large'] 
  allow_blank: true
  
theUser.validates "my_field", test: "presence"
  
describe "inclusion with a separate presence test", ->
  model = null
  
  beforeEach ->
    model = new UserWithPresence


  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("My field can't be empty")

  it "fails when null", ->
    model.populate({ email: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("My field can't be empty")
    
  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("My field can't be empty")

  it "fails when extra large", ->
    model.populate({ my_field: "extra large" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "passes when small", ->
    model.populate({ my_field: "small" });
    expect(model.isValid()).toBeTruthy()

  it "passes when medium", ->
    model.populate({ my_field: "medium" });
    expect(model.isValid()).toBeTruthy()

  it "passes when large", ->
    model.populate({ my_field: "large" });
    expect(model.isValid()).toBeTruthy()


# Make sure it doesn't bomb if the client forgot to supply an "in" array.
# Nothing should pass.

theUser = class UserWithNoIn extends MVCoffee.Model

theUser.validates "my_field", test: 'inclusion'
  


describe "inclusion with no 'in' list provided", ->
  model = null
  
  beforeEach ->
    model = new UserWithNoIn



  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when null", ->
    model.populate({ email: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when blank", ->
    model.populate({ email: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when extra large", ->
    model.populate({ my_field: "extra large" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when large", ->
    model.populate({ my_field: "large" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when medium", ->
    model.populate({ my_field: "medium" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

  it "fails when small", ->
    model.populate({ my_field: "small" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is not included in the list')

