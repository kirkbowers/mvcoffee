MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates "my_field", 
  test: 'exclusion'
  in: ['www', 'us', 'ca', 'jp']
  allow_blank: true
  
# I'm using the allow blank flag in this test suite because I just can't see a use
# case in which you wouldn't either allow blank (because it is, in fact, not in the
# array of disallowed values), or you'd enforce non-blank with a separate presence
# test in order to make the error message more meaningful.

describe "exclusion", ->
  model = null
  
  beforeEach ->
    model = new User

  it "fails when www", ->
    model.populate({ my_field: "www" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is reserved')

  it "fails when us", ->
    model.populate({ my_field: "us" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is reserved')

  it "fails when ca", ->
    model.populate({ my_field: "ca" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is reserved')

  it "fails when jp", ->
    model.populate({ my_field: "jp" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is reserved')

  it "passes when wwww", ->
    model.populate({ my_field: "wwww" });
    expect(model.isValid()).toBeTruthy()

  it "passes when something completely different", ->
    model.populate({ my_field: "something completely different" });
    expect(model.isValid()).toBeTruthy()

  it "passes when blank", ->
    model.populate({ my_field: "" });
    expect(model.isValid()).toBeTruthy()



theUser = class UserWithPresence extends MVCoffee.Model

theUser.validates "my_field", 
  test: 'exclusion'
  in: ['www', 'us', 'ca', 'jp']
  allow_blank: true

theUser.validates "my_field", test: "presence"

describe "exclusion with separate presence validator", ->
  model = null
  
  beforeEach ->
    model = new UserWithPresence

  it "fails when www", ->
    model.populate({ my_field: "www" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is reserved')

  it "fails when us", ->
    model.populate({ my_field: "us" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is reserved')

  it "fails when ca", ->
    model.populate({ my_field: "ca" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is reserved')

  it "fails when jp", ->
    model.populate({ my_field: "jp" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is reserved')

  it "passes when wwww", ->
    model.populate({ my_field: "wwww" });
    expect(model.isValid()).toBeTruthy()


  it "passes when something completely different", ->
    model.populate({ my_field: "something completely different" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("My field can't be empty")



theUser = class UserWithNoIn extends MVCoffee.Model

theUser.validates "my_field", 
  test: 'exclusion'
  allow_blank: true


# Make sure it doesn't bomb if the client forgot to supply an "in" array.
# Everything should pass.
describe "exclusion with no 'in' list provided", ->
  # TODO!!!
  model = null
  
  beforeEach ->
    model = new UserWithNoIn


  it "passes when www", ->
    model.populate({ my_field: "www" });
    expect(model.isValid()).toBeTruthy()

  it "passes when wwww", ->
    model.populate({ my_field: "wwww" });
    expect(model.isValid()).toBeTruthy()

  it "passes when something completely different", ->
    model.populate({ my_field: "something completely different" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when blank", ->
    model.populate({ my_field: "" });
    expect(model.isValid()).toBeTruthy()


