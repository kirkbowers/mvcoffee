MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model


store = null
      
describe "models with out of order data", ->
  beforeEach ->
    store = new MVCoffee.ModelStore
      user: User
  
    store.load
      mvcoffee_version: "1.0.0"
      models:
        user:
          data: [
            id: 1
            name: "Bob"
          ,
            id: 2
            name: "Sue"
          ,
            id: 3
            name: "danny"
          ]        

  it "should return all users in ascending lexicographic order", ->
    users = User.all order: 'name'
    expect(users.length).toBe(3)
    expect(users[0].name).toBe("Bob")
    expect(users[0].id).toBe(1)
    expect(users[1].name).toBe("Sue")
    expect(users[1].id).toBe(2)
    expect(users[2].name).toBe("danny")
    expect(users[2].id).toBe(3)
    
  it "should return all users in ascending ignored case order", ->
    users = User.all order: 'name', ignoreCase: true
    expect(users.length).toBe(3)
    expect(users[0].name).toBe("Bob")
    expect(users[0].id).toBe(1)
    expect(users[1].name).toBe("danny")
    expect(users[1].id).toBe(3)
    expect(users[2].name).toBe("Sue")
    expect(users[2].id).toBe(2)
    

  it "should return all users in descending lexicographic order", ->
    users = User.all order: 'name desc'
    expect(users.length).toBe(3)
    expect(users[0].name).toBe("danny")
    expect(users[0].id).toBe(3)
    expect(users[1].name).toBe("Sue")
    expect(users[1].id).toBe(2)
    expect(users[2].name).toBe("Bob")
    expect(users[2].id).toBe(1)
    

  it "should return all users in descending ignored case order", ->
    users = User.all order: 'name desc', ignoreCase: true
    expect(users.length).toBe(3)
    expect(users[0].name).toBe("Sue")
    expect(users[0].id).toBe(2)
    expect(users[1].name).toBe("danny")
    expect(users[1].id).toBe(3)
    expect(users[2].name).toBe("Bob")
    expect(users[2].id).toBe(1)
