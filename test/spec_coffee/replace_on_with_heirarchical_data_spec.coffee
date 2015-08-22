MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.hasMany "activity", order: "position"


theActivity = class Activity extends MVCoffee.Model

theActivity.belongsTo "user"

store = new MVCoffee.ModelStore
  user: User
  activity: Activity

first_data = {
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
        ]
      ]

}


second_data = {
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
          name: "Rake the leaves"
        ,
          id: 3
          user_id: 2
          name: "Eat some ice cream"
        ]
      ]
    activity:
      replace_on: { user_id: 2 }
}

describe "replacing on with hierarchical data", ->
  it "should perform deletes for replace on before loading data", ->
    store.load first_data
    user = User.find(2)
    expect(user.name).toBe("Sue")
    expect(Activity.all().length).toBe(2)
    activities = user.activities()
    expect(activities.length).toBe(2)
    expect(activities[0].name).toBe("Rake the yard")
    expect(activities[0].id).toBe(1)
    expect(activities[1].name).toBe("Make a sandwich")
    expect(activities[1].id).toBe(2)

    # The key here is, even though the command to load the data into user is supplied
    # before the command to replace_on item (and even though the order these are defined
    # may have no influence on what order they come out in a for ... of),
    # the deletions should be performed _before_ the user data is loaded, and there 
    # should be no merge of old data with new.

    store.load second_data
    user = User.find(2)
    expect(user.name).toBe("Sue")
    expect(Activity.all().length).toBe(2)
    activities = user.activities()
    expect(activities.length).toBe(2)
    expect(activities[0].name).toBe("Rake the leaves")
    expect(activities[0].id).toBe(1)
    expect(activities[1].name).toBe("Eat some ice cream")
    expect(activities[1].id).toBe(3)
    


