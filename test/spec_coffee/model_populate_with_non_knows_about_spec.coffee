MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model


store = new MVCoffee.ModelStore
  user: User
  
store.load
  mvcoffee_version: "1.0.0"
  models:
    user:
      data: [
        id: 1
        name: "Bob"
        primes: [1, 2, 3, 5, 7]
      ]
      
describe "models with hierarchical data that isn't known about", ->
  it "should have a simple array for non-known about complex property", ->
    user = User.find(1)
    expect(user.name).toBe("Bob")
    expect(user.primes.length).toBe(5)
    expect(user.primes[0]).toBe(1)
    expect(user.primes[1]).toBe(2)
    expect(user.primes[2]).toBe(3)
    expect(user.primes[3]).toBe(5)
    expect(user.primes[4]).toBe(7)

