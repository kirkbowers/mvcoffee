MVCoffee = require("../lib/mvcoffee")


theUser = class User extends MVCoffee.Model
  custom: (val) ->
    val is "valid" or val is "kosher" or val is "the dude abides"

theUser.validates "my_field", test: "custom"
 
describe "custom validator", ->
  model = null
  
  beforeEach ->
    model = new User

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')
    
  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when not one of the three acceptable values", ->
    model.populate({ my_field: "unacceptable" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "passes when valid", ->
    model.populate({ my_field: "valid" });
    expect(model.isValid()).toBeTruthy()

  it "passes when kosher", ->
    model.populate({ my_field: "kosher" });
    expect(model.isValid()).toBeTruthy()

  it "passes when the dude abides", ->
    model.populate({ my_field: "the dude abides" });
    expect(model.isValid()).toBeTruthy()
    
# The above set of tests pretty much prove it works as intended, but I added this
# set just as a sanity check since I use the modByThree as an example in the 
# README docs.

theUser = class UserModBy3 extends MVCoffee.Model
  modByThree: (val) ->
    parseFloat(val) % 3 is 0

theUser.validates "my_field", test: "modByThree"

describe "custom validator working with a number", ->
  model = null
  
  beforeEach ->
    model = new UserModBy3

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')
    
  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when not a number", ->
    model.populate({ my_field: "unacceptable" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when a float", ->
    model.populate({ my_field: "3.1" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "fails when an int not divis by 3", ->
    model.populate({ my_field: "5" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is invalid')

  it "passes when 3", ->
    model.populate({ my_field: "3" });
    expect(model.isValid()).toBeTruthy()

  it "passes when 81", ->
    model.populate({ my_field: "81" });
    expect(model.isValid()).toBeTruthy()


#----------------------------------------------

theUser = class UserWithTypo extends MVCoffee.Model
  custom: (val) ->
    val is "valid" or val is "kosher" or val is "the dude abides"

theUser.validates "my_field", test: "custom_typo"


describe "non-existent custom validator", ->

  model = null
  
  beforeEach ->
    model = new UserWithTypo

  it "fails with any input", ->
    expect(-> 
      model.populate({ my_field: "valid" }) 
    ).toThrow(
        "custom validation is not a function"
    )
    
