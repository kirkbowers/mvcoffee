MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates "email", test: "email"
  
describe "validates email", ->
  model = null
  
  beforeEach ->
    model = new User

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')

  it "fails when null", ->
    model.populate({ email: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')

  it "fails when blank", ->
    model.populate({ email: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')

  it "fails when no at signs", ->
    model.populate({ email: "joe" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')

  it "fails when no dot suffix", ->
    model.populate({ email: "joe@foo" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')
    
  it "fails when two ats", ->
    model.populate({ email: "joe@blow@foo.com" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')
    
  it "succeeds with good email", ->
    model.populate({ email: "joe.blow@foo.com" });
    expect(model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(0)


#-------------------------------------------------------

theUser = class UserWithDisplay extends MVCoffee.Model

theUser.displays "email", "Email Address"
theUser.validates "email", test: "email"


describe "email with display name", ->
  model = null
  
  beforeEach ->
    model = new UserWithDisplay

  it "fails when no at signs", ->
    model.populate({ email: "joe" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email Address must be a valid email address')


#-------------------------------------------------------

theUser = class UserWithMessage extends MVCoffee.Model

theUser.validates "email", test: "email", message: "has a custom message"


describe "email with custom message", ->
  model = null
  
  beforeEach ->
    model = new UserWithMessage

  it "fails when no at signs", ->
    model.populate({ email: "joe" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email has a custom message')

#-------------------------------------------------------

theUser = class UserAllowNull extends MVCoffee.Model

theUser.validates "email", test: "email", allow_null: true

  
describe "email allows null", ->
  model = null
  
  beforeEach ->
    model = new UserAllowNull

  it "passes when undefined", ->
    model.validate();
    expect(model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(0)

  it "passes when null", ->
    model.populate({ email: null });
    expect(model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(0)

  it "fails when blank", ->
    model.populate({ email: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')

  it "fails when no at signs", ->
    model.populate({ email: "joe" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')

  it "fails when no dot suffix", ->
    model.populate({ email: "joe@foo" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')
    
  it "fails when two ats", ->
    model.populate({ email: "joe@blow@foo.com" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')
    
  it "succeeds with good email", ->
    model.populate({ email: "joe.blow@foo.com" });
    expect(model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(0)

#-------------------------------------------------------

theUser = class UserWithPresenceTest extends MVCoffee.Model

theUser.validates "email", test: "presence"
theUser.validates "email", test: "email", allow_blank: true


describe "email allows blank with presence test", ->
  model = null
  
  beforeEach ->
    model = new UserWithPresenceTest

  it "only one error when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email can't be empty")

  it "only one error when null", ->
    model.populate({ email: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email can't be empty")

  it "only one error when blank", ->
    model.populate({ email: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual("Email can't be empty")

  it "fails when no at signs", ->
    model.populate({ email: "joe" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Email must be a valid email address')

  it "succeeds with good email", ->
    model.populate({ email: "joe.blow@foo.com" });
    expect(model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(0)

