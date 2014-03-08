MVCoffee = require("../lib/mvcoffee")


theModel = class User extends MVCoffee.Model

theModel.displays "barf", "Horf"

theModel.validates "barf", test: "presence"

describe "the displays macro method adds typing to a new field", ->

  it "should create a new barf property on fields list", ->
    user = new User()
    expect(user.fields.length).toBe(1)
    expect(user.fields[0].name).toBe("barf")
    expect(user.fields[0].display).toBe("Horf")

  it "should use the custom display name in error messages", ->
    user = new User({barf: "" })
    expect(user.errors[0]).toMatch(/^Horf/)
