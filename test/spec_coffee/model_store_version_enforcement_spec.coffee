MVCoffee = require("../lib/mvcoffee")


theUser = class User extends MVCoffee.Model

describe "ModelStore enforces version of data", ->
  # This makes sure store is declared in this scope
  store = null
  
  MIN_DATA_FORMAT_VERSION = "1.0.0"

  beforeEach ->
    store = new MVCoffee.ModelStore
      user: User
      
  it "bombs if incoming data has no version number", ->
    data =
      models:
        user:
          data: [
            id: 1
            name: "Joe"
          ,
            id: 2
            name: "Biff"
          ]

    expect(-> 
      store.load(data) 
    ).toThrow(
        "MVCoffee.DataStore requires minimum data format " + MIN_DATA_FORMAT_VERSION
    )

  it "bombs if incoming data has version number below the min", ->
    data =
      version: "0.3.2"
      models:
        user:
          data: [
            id: 1
            name: "Joe"
          ,
            id: 2
            name: "Biff"
          ]

    expect(-> 
      store.load(data) 
    ).toThrow(
        "MVCoffee.DataStore requires minimum data format " + MIN_DATA_FORMAT_VERSION
    )

  it "succeeds if incoming data has version number at the min", ->
    data =
      version: "1.0.0"
      models:
        user:
          data: [
            id: 1
            name: "Joe"
          ,
            id: 2
            name: "Biff"
          ]

    store.load(data) 
    users = User.all()
    expect(users.length).toBe(2)

  it "succeeds if incoming data has version number above the min", ->
    data =
      version: "1.0.1"
      models:
        user:
          data: [
            id: 1
            name: "Joe"
          ,
            id: 2
            name: "Biff"
          ]

    store.load(data) 
    users = User.all()
    expect(users.length).toBe(2)

