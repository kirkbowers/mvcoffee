MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates 'email', test: 'confirmation'

# The 'email_confirmation' property should be implied
  
describe "confirmation", ->
  model = null
  
  beforeEach ->
    model = new User

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when null and confirm undefined", ->
    model.populate({ email: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when blank and confirm undefined", ->
    model.populate({ email: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when null and confirm null", ->
    model.populate({ email: null, email_confirmation: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when blank and confirm null", ->
    model.populate({ email: "", email_confirmation: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when null and confirm blank", ->
    model.populate({ email: null, email_confirmation: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when blank and confirm blank", ->
    model.populate({ email: "", email_confirmation: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when blank and confirm something", ->
    model.populate({ email: "", email_confirmation: "foo@somewhere.com" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when something and confirm blank", ->
    model.populate({ email: "foo@somewhere.com", email_confirmation: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when something and confirm something else", ->
    model.populate({ email: "foo@somewhere.com", email_confirmation: "fob@somewhere.com" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "passes when something and confirm matches", ->
    model.populate({ email: "foo@somewhere.com", email_confirmation: "foo@somewhere.com" });
    expect(model.isValid()).toBeTruthy()

#----------------------------------------------
# Try with allow blank

theUser = class UserAllowBlank extends MVCoffee.Model

theUser.validates 'email', test: 'confirmation', allow_blank: true


describe "confirmation", ->
  model = null
  
  beforeEach ->
    model = new UserAllowBlank

  it "passes when undefined", ->
    model.validate();
    expect(model.isValid()).toBeTruthy()

  it "passes when null and confirm undefined", ->
    model.populate({ email: null });
    expect(model.isValid()).toBeTruthy()

  it "passes when blank and confirm undefined", ->
    model.populate({ email: "" });
    expect(model.isValid()).toBeTruthy()

  it "passes when null and confirm null", ->
    model.populate({ email: null, email_confirmation: null });
    expect(model.isValid()).toBeTruthy()

  it "passes when blank and confirm null", ->
    model.populate({ email: "", email_confirmation: null });
    expect(model.isValid()).toBeTruthy()

  it "passes when null and confirm blank", ->
    model.populate({ email: null, email_confirmation: "" });
    expect(model.isValid()).toBeTruthy()

  it "passes when blank and confirm blank", ->
    model.populate({ email: "", email_confirmation: "" });
    expect(model.isValid()).toBeTruthy()

  it "fails when something and confirm blank", ->
    model.populate({ email: "foo@somewhere.com", email_confirmation: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "fails when something and confirm something else", ->
    model.populate({ email: "foo@somewhere.com", email_confirmation: "fob@somewhere.com" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email doesn't match confirmation")

  it "passes when something and confirm matches", ->
    model.populate({ email: "foo@somewhere.com", email_confirmation: "foo@somewhere.com" });
    expect(model.isValid()).toBeTruthy()

