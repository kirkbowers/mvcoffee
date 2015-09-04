MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.hasMany "activity", order: "position"


theActivity = class Activity extends MVCoffee.Model

theActivity.belongsTo "user"
theActivity.hasMany "subactivity"


theSubActivity = class Subactivity extends MVCoffee.Model

theSubActivity.belongsTo "activity"

store = null
      
describe "models with hierarchical data", ->
  beforeEach ->
    store = new MVCoffee.ModelStore
      user: User
      activity: Activity
      subactivity: Subactivity
  
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
            activity: [
              id: 1
              user_id: 2
              name: "Rake the yard"
            ,
              id: 2
              user_id: 2
              name: "Make a sandwich"
              subactivity: [
                id: 1
                activity_id: 2
                name: "Spread peanut butter"
              ,
                id: 2
                activity_id: 2
                name: "Spread jelly"
              ]
            ]
          ]


  it "should delete a model that has no has many things and leave others untouched", ->
    user = User.find 1
    user.delete()
    expect(User.all().length).toBe(1)
    expect(User.find(1)).toBeUndefined()
    user = User.find 2
    expect(user.name).toBe("Sue")
    expect(user.activities().length).toBe(2)
    sandwich = Activity.find(2)
    expect(sandwich.name).toBe("Make a sandwich")
    expect(sandwich.subactivities().length).toBe(2)

  it "should cascade a delete on a model that has many children", ->
    user = User.find 2
    user.delete()
    expect(User.all().length).toBe(1)
    expect(User.find(2)).toBeUndefined()
    user = User.find 1
    expect(user.name).toBe("Bob")
    expect(user.activities().length).toBe(0)
    expect(Activity.all().length).toBe(0)
    expect(Subactivity.all().length).toBe(0)
        
  it "should cascade a delete on a model that has many children using destroy alias", ->
    user = User.find 2
    user.destroy()
    expect(User.all().length).toBe(1)
    expect(User.find(2)).toBeUndefined()
    user = User.find 1
    expect(user.name).toBe("Bob")
    expect(user.activities().length).toBe(0)
    expect(Activity.all().length).toBe(0)
    expect(Subactivity.all().length).toBe(0)
        
  it "should cascade a delete when done by a load on the store using a scalar", ->
    store.load
      mvcoffee_version: "1.0.0"
      models:
        user:
          delete: 2
          
    expect(User.all().length).toBe(1)
    expect(User.find(2)).toBeUndefined()
    user = User.find 1
    expect(user.name).toBe("Bob")
    expect(user.activities().length).toBe(0)
    expect(Activity.all().length).toBe(0)
    expect(Subactivity.all().length).toBe(0)
    
  it "should cascade a delete when done by a load on the store using an array", ->
    store.load
      mvcoffee_version: "1.0.0"
      models:
        user:
          delete: [1, 2]
          
    expect(User.all().length).toBe(0)
    expect(Activity.all().length).toBe(0)
    expect(Subactivity.all().length).toBe(0)
   
  it "should not cascade a delete when done by a load on the store using replace_on", ->
    store.load
      mvcoffee_version: "1.0.0"
      models:
        activity:
          data: [
            id: 2
            user_id: 2
            name: "Make a nice sandwich"
          ,
            id: 3
            user_id: 2
            name: "Make spaghetti"
          ]
          replace_on:
            user_id: 2
          
    expect(User.all().length).toBe(2)
    user = User.find 1
    expect(user.name).toBe("Bob")
    expect(user.activities().length).toBe(0)
    user = User.find 2
    expect(user.name).toBe("Sue")
    activities = user.activities()
    expect(activities.length).toBe(2)
    act = activities[0]
    expect(act.name).toBe("Make a nice sandwich")
    expect(act.subactivities().length).toBe(2)
    expect(Subactivity.all().length).toBe(2)
    act = activities[1]
    expect(act.name).toBe("Make spaghetti")
    expect(act.subactivities().length).toBe(0)
    
 
    