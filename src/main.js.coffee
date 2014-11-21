###

MVCoffee

Copyright 2014, Kirk Bowers
MIT License

Version 1.0.0

###

# Make sure there is an MVCoffee object on the global namespace

# This little bit of mojo lets us export things into node.js and letting node's 
# exports mechanism handle namespacing for us.  You'd do this in node land:
#     var MVCoffee = require('mvcoffee');
if exports?
  MVCoffee = exports
else
  # On the other hand, in the more likely case we are not in node, we need to create
  # an MVCoffee object on the global object, then assign the local MVCoffee variable
  # created by the above assignment as an alias to the object of the same name on this.
  this.MVCoffee || (this.MVCoffee = {})
  MVCoffee = this.MVCoffee
  
# polyfill Array.isArray, just in case
if !Array.isArray
  Array.isArray = (arg) ->
    Object.prototype.toString.call(arg) is '[object Array]'

# At the risk of polluting the global namespace, add the rails style "link_to" function
this.link_to = (label, link, opts = {}) ->
  result = '<a href="' + link + '"'
  if opts.id?
    result += ' id="' + opts.id + '"'
  if opts.class?
    result += ' class="' + opts.class + '"'
    
  result += '>' + label + '</a>'
  
  result
