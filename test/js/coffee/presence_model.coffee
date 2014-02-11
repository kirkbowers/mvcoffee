# In the extreme off chance this were used as a node module, exports should come in
# non-null, but otherwise put our exports on the global namespace.
root = this ? exports

class PresenceModel extends MVCoffee.Model
  fields: [
    {
      name: 'present'
      validates: [
        { test: 'presence' }
      ]
    },
    {
      name: 'present_with_message'
      validates: [
        { test: 'presence', message: 'must have a custom message' }
      ]
    },
    {
      name: 'present_with_display'
      display: 'Display Name'
      validates: [
        { test: 'presence' }
      ]
    },
    {
      name: 'present_with_unless'
      validates: [
        { test: 'presence', unless: 'canSkip' }
      ]
    }
  ]
  
  canSkip: ->
    @skip


root.PresenceModel = PresenceModel