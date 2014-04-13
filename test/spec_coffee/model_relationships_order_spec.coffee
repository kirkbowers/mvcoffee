MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.hasMany "activity", order: "position"
theUser.hasMany "activity", as: "reversed", order: "position desc"

theActivity = class Activity extends MVCoffee.Model

theActivity.belongsTo "user"


store = new MVCoffee.ModelStore
  user: User
  activity: Activity
  
store.load
  models:
    user: [
      id: 1
      name: "Bob"
    ,
      id: 2
      name: "Sue"
    ]
    activity: [
      id: 1
      name: "Rake the yard"
      position: 2
      user_id: 1
      owner_id: 1
    ,
      id: 2
      name: "Sweep the driveway"
      position: 1
      user_id: 1
      owner_id: 2
    ,
      id: 3
      name: "Wash the cat"
      position: 1
      user_id: 2
      owner_id: 1
    ]
  
describe "model macro methods for relationships with options", ->
  it "should find activities for a user in ascending order by position", ->
    user = User.find(1)
    acts = user.activities()
    expect(acts instanceof Array).toBeTruthy()
    expect(acts.length).toBe(2)
    expect(acts[0].name).toBe("Sweep the driveway")
    expect(acts[1].name).toBe("Rake the yard")
    expect(acts[0].position).toBe(1)
    expect(acts[1].position).toBe(2)
    
  it "should find activities for a user in descending order by position", ->
    user = User.find(1)
    acts = user.reversed()
    expect(acts instanceof Array).toBeTruthy()
    expect(acts.length).toBe(2)
    expect(acts[0].name).toBe("Rake the yard")
    expect(acts[1].name).toBe("Sweep the driveway")
    expect(acts[0].position).toBe(2)
    expect(acts[1].position).toBe(1)
