# In the extreme off chance this were used as a node module, exports should come in
# non-null, but otherwise put our exports on the global namespace.
root = this ? exports

# This is a very simple shell of a model class just for testing that population works
# as expected.  We don't need to do much validation, just make sure the values get
# populated from various sources as we expect.  The only validation I do is to make 
# sure that a number coming from a "text" input does in fact turn into a number.
# There are two booleans so we can try both a checked and unchecked checkbox in the UI.

class PopulationModel extends MVCoffee.Model
  modelName: 'population'
  fields: [
    {
      name: 'city'
    },
    {
      name: 'description'
    },
    {
      name: 'population',
      validates: { test: 'numericality', only_integer: true }
    },
    {
      name: 'has_great_brewpubs',
      type: 'boolean'
    },
    {
      name: 'is_warm_in_winter'
      type: 'boolean'
    }
  ]
  

root.PopulationModel = PopulationModel