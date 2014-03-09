# MVCoffee

MVC: Model, View,... Coffee!

MVCoffee is (yet another) lightweight client-side MVC implementation for web
applications.  As the name implies, it is written in CoffeeScript.  It is designed to
support a specific approach to web development:

* It facilitates a hybrid between the Single Page Application (SPA) approach and 
old-school html served by the server, allowing for bookmarkable URL-driven navigation
through your site with enhanced client-side interactivity and Ajax-driven performance
improvements.  It is tailored to provide this especially well when used with 
[Ruby on Rails](http://rubyonrails.org) and the 
[jQuery Turbolinks](https://github.com/kossnocorp/jquery.turbolinks) gem.
* It allows a "progressive enhancement" approach in the off chance users have 
JavaScript disabled.  It also works quite well, again with rails and turbolinks, 
caching data and doing most of the rendering client-side if you require that JavaScript
be enabled.
* It's expected that users may have the site running on multiple browsers (Safari, Chrome, 
Firefox, ...), or more likely on multiple devices (laptop, iPad, ...).  Persisting data
on the client therefore runs the risk of becoming stale and inconsistent.  The server
must be the master source for the data, and it should be easy to refresh potentially stale
data, both periodically and when a browser window regains focus.
MVCoffee handles knowing when to trigger a refresh and provides a life cycle model
(start, pause, resume, stop) for controllers, you just have to supply the callbacks.
* If the server is the master source of the data, it is ultimately responsible for
validation.  However, client-side validation improves performance and user experience,
so is beneficial.  Unfortunately, it violates DRY (don't repeat yourself).  It's 
duplicated effort to write the same validations on both client and server, and those 
can easily become out of sync.  MVCoffee tries to reduce the impact of this by providing
a model validation API that very closely mimics Rails' ActiveRecord validations.  In most 
cases it's a straight translation from Rails `validates` macro methods to CoffeeScript
macro methods with a very similar syntax.

<a name="whats-new"></a>
# What's new in 0.2

Version 0.2 introduces many improvements over 0.1.

* Macro methods!  Specify model validations now with a macro method syntax very similar
to Rails.
* Improved client-side caching in the new ModelStore that supports basic querying.
* Relationships between models now supported, also with Rails style syntax for 
declaring `has_many` and `belongs_to` relationships.
* Auto-pluralization of model names in relationships (albeit somewhat primitive).
* Can run more than one controller at a time, so different controllers can handle 
parts of the page with different refresh policies.
* Cleaner syntax for registering controllers with the controller manager.
* All non-interactive tests ported to `jasmine-node` for running on the command line
(instead of using QUnit in a browser).

<a name="dependencies"></a>
# Dependencies

* To use the already compiled (and optionally minified) `.js` file in your project, 
the only dependency is [jQuery](http://jquery.com).
* To compile the code from source, your need [CoffeeScript](http://jashkenas.github.io/coffee-script/) which depends on [Node.js](http://nodejs.org).
* To minify the compiled JavaScript, you need to have [uglifyJS](https://npmjs.org/package/uglify-js) in your executable path.
* To locally compile markdown documentation files into html, you need [Markdown.pl](https://daringfireball.net/projects/markdown/) in your executable path.
* All non-interactive tests depend on [jasmine-node](https://github.com/mhevery/jasmine-node).
Some legacy tests as well as some that do require visual verification in a webpage 
depend on [jQuery](http://jquery.com) and [QUnit](http://qunitjs.com), but fetch them both from a CDN.  There are pre-rolled black box tests that depend on 
[Ruby on Rails](http://rubyonrails.org) and 
[jQuery Turbolinks](https://github.com/kossnocorp/jquery.turbolinks).  Also, for 
completeness sake there is a [nodeunit](https://github.com/caolan/nodeunit)
sanity check, just to see if the library loads as a node package.
* Some of the tasks in the Cakefile depend on [execSync](https://www.npmjs.org/package/execSync).

<a name="usage"></a>
# Usage

<a name="installation"></a>
## Installation and Recommended Project Setup

To use MVCoffee, all you have to do is include the minified `.js` file in your project
add import it with a script tag before all of your controller and model declarations.
If you are using Rails, you can use the non-minified version and the asset pipeline
should minify it for you in production (doing so makes your `application.js` file
read a little better).

You can build it from source by running in the root directory of the project:

    cake build
    
to build the `.js` file into the `lib` directory or

    cake minify
    
to both compile the CoffeeScript to JavaScript and then minify it into the `lib`
directory.

If you are using Rails and the Sprockets driven asset pipeline, you can drop the 
regular `.js` file in your `vender/assets/javascripts` directory.  Preferably, instead of
the usual `//= require_tree .` that appears in a default Rails project setup, you would
control the order of loading in your `application.js` file like so:

    //= require mvcoffee
    //= require_directory ./models
    //= require_directory ./templates
    //= require_directory ./controllers
    //= require manager
    
Your models, views and controllers go in the `models`, `templates` and `controllers` 
directories, respectively (most likely `app/assets/javascripts/models`, etc.).  The
manager file will be discussed in the sections
["Model store and queries"](#model-store) and
["Registering Controllers with the Controller Manager"](#controller-manager).

<a name="models"></a>
## Models

MVCoffee models are very lightweight.  They do not persist on the client, or save
themselves through a RESTful interface (although, I could see that being future feature).
They do populate themselves automatically from input forms using jQuery, and they do
validate themselves as long as you've provided the model with the correct metadata.

A model is defined by extending MVCoffee.Model, then call macro methods on the model
to define validations and relationships.  
Here's an example (you would probably namespace the
class names `User` and `Item`, but I'm keeping it simple for readability):

    user = class User extends MVCoffee.Model
    user.validates "name", test: "presence"
    user.has_many "item"
    
    item = class Item extends MVCoffee.Model
    item.displays "name", "Item name"
    item.validates "name", test: "presence"
    item.validates "quantity_desired",
      test: "numericality"
      allow_blank: true
      only_integer: true
      greater_than:
        value: 0
        message: 'must be greater than zero'
    item.types 'unlimited', 'boolean'
    item.belongs_to 'user'

<a name="model-metadata"></a>
### Model Metadata and macro methods

<a name="model-modelName"></a>
#### modelName

The modelName property has two uses: identification in the model store and use during
model validation.  It should be the singular, lowercased, snake-cased version of your
model name (eg. `crazy_person` for `CrazyPerson`).

If the model is stored in the `ModelStore`, it is stored keyed by this name.  In this
case, you do not need to set this property manually.  You supply it as the key for this
model when you register it with the model store.  This will be described in the 
section describing the model store.

For validation purposes,  the `modelName` property is used for helping determine 
the ids of the input fields in a form.  The Rails `form_for` construct prepends this 
name and an underscore before all field names.  If you are not using Rails (or if you 
used the `form_tag` construct) and construct input field ids by hand, you should 
either not supply this property, or manually set the ids on input fields in html
to match.  For example, the text field input for `CrazyPerson.name` should look like 
this:

    <input type="text" id="crazy_person_name">

<a name="model-fields"></a>
#### fields

**NOTE: Setting the `fields` property manually is deprecated!** It still works, for
backwards compatibility, and because the preferred macro methods manipulate this
data structure, so the documentation remains here for completeness-sake.

The `fields` property is an array of object literals, each corresponding to a data field
in the model.  The "name" property is required, all others are optional.  The possible 
properties for each field are:

* `name:` This should match the name of the column in the database this field maps to.
If you are using the Rails `form_for` construct, this name will be used together with
the "modelName" to help jQuery glean the value of this field from the input form.
Also, if the "display" property is not supplied, any error messages for this field
will use the Rails-style non-codish version of this name (first letter capitalized, 
underscores replaced with spaces).
* `display:` If you want to override the default humanized name of a field in error 
messages, you can set that value here (eg. a field named "phone_num" would display
as "Phone num" by default, but you can override the "display" as "Telephone number").
* `type:` All fields are assumed to be strings and assumed to come from either an
input[type="text"] or textarea unless a different type is supplied here.  "boolean"
will cause the field to be populated based on whether it is ":checked".
* `validates:` Takes either an object literal defining one validation test to be performed
on this field after it has been populated, or an array of object literals if more than
on validation is to be performed.  Validations are discussed below in depth.

Once a model has been populated, all its fields are accessible through normal 
JavaScript dot notation and square bracket notation.

The preferred way to set these values is using macro methods.  For convenience, when 
you declare a model class, you can assign the declaration to a shorthand temporary
variable like "it" (if you aren't in jasmine-land), and a lowercase version of the 
class name.  Macro method calls follow the class definition, and follow this form:

    thing = class Thing extends MVCoffee.Model
    
    thing.displays "phone_num", "Telephone number"
    thing.types "groovy", "boolean"
    thing.validates "name", test: "presence"

<a name="model-population"></a>
### Model population

There are three ways to populate a model.  The first two will validate the model 
automatically.  The third (manual field-by-field) requires a call to the `validate()`
method once population is done.

* Supply an object to the constructor.  This is most useful for populating a model that
has been supplied by JSON from the server.  You can also supply an object literal to 
the constructor.  This would work for the Item model shown above:

        item = new Item({
          name: 'CoffeeScript book',
          quantity_desired: 1,
          unlimited: false
        })

* Call the `populate()` method on an already instantiated model.  You can pass an object
to `populate` just as you would to the constructor.  If no argument is given to 
`populate`, it will try to populate from an input form on the page using jQuery.

        item = new Item()
        # This uses jQuery to glean the values from the page
        item.populate()

* Manually populate the fields using dot notation.

        item = new Item()
        item.name = 'CoffeeScript book'
        item.quantity_desired = 1
        item.validate()
    
<a name="model-validation"></a>
### Validation

When a model is populated, or when the validate method is called manually, all validations
are run on the model and the result is reflected in two properties of the model.  You
can call the method `isValid()` to get a boolean value, and/or you can inspect the 
`errors` property.  `errors` is an array of string error messages, very similar to the
errors array in Rails.

The syntax for specifying validations tries to mimic the Rails syntax as closely as 
possible to try to ease the pain of not being DRY, but since JavaScript/CoffeeScript 
is a very different language than Ruby, there are some notable differences.  Each
validation test is specified as an object literal with the property `test:` specifying
the name of the test as a string.  So this Rails test:

      validates :first_name, presence: true
    
becomes (using the macro methods described above on a shorthand class ref `it`):

    it.validates "first_name", test: 'presence'
    
All tests allow 5 optional "flag" properties:

* `message:`  let's you override the error message to be appended to the field name if 
the test doesn't pass.  If you do not want the field name as part of the message, you 
can set the field's `display` property to the empty string.

        it.validates 'some_field', test: 'presence', message: 'must not be blank'

* `allow_null:`  if true causes the test not to be executed if the field is either 
undefined or null.  Note the different spelling from Rails, as in JavaScript it's "null" 
instead of "nil".

        it.validates 'some_field', test: 'numericality', allow_null: true

* `allow_blank:`  causes the test not to be executed if the field is undefined, null,
the empty string or only whitespace.

        it.validates 'some_field', test: 'numericality', allow_null: true

* `only_if:`  causes the test to only be executed if the method named as the value for
`only_if:` returns true (or any truthy value).  This is similar to the `if:` symbol 
in Rails, but is named `only_if:` since "if" is a reserved word in JavaScript and it's 
not ideal to use it as a property name.  The value for `only_if:` must be a string that 
is the name of a method on the model.  

        it = class SomeModel extends MVCoffee.Model
          termsAccepted: ->
            # Some nifty calculation that results in a boolean

        it.validates 'some_field', test: 'presence', only_id: "termsAccepted"
    
      
* `unless:`  works just like `only_if:`, but causes the test to be executed only if the
method supplied returns false (or any falsy value).

Some validation tests also allow subvalidations.  The subvalidations allow for their
own `message:`, `only_if:`, and `unless:` flags that trump the parent validation's values.
See "numericality" and "length" below for examples.

A list of all possible tests follows.  Most of the tests provided by Rails exist in
MVCoffee as well, although those that require a database check and can't be done purely
client-side, such as "uniqueness", are not provided (for obvious reasons).

#### acceptance

This test requires that the user has somehow populated the given field to indicate
acceptance of something (likely terms of service).  It defaults to requiring that the
field equal "1", but can be overridden with the `accept:` property.  The default
error message is "must be accepted".

    it.validates 'some_field', test: 'acceptance', accept: true
      
#### confirmation

This test checks that the field it's associated with matches a field with the same name
as this one suffixed with "`_confirmation`".  Unless `allow_blank:` is set, it requires
that the two fields are populated.  The default error message is "doesn't match 
confirmation".

    it.validates 'password', test: 'confirmation'

#### email

This is a bonus test not supplied in Rails.  It checks the field against a fairly
nasty regular expression that I believe captures the legal format of an email 
address.  No guarantees, of course.  The default error message is "must be a valid
email address".

    it.validates 'email', test: 'email'
      
#### exclusion

This test passes only if the field value is not in the supplied array of values.
The array of values to test against are supplied as the `in:` property.  If no `in:` is
supplied, every non-blank value passes.  The default error message is "is reserved".

    it.validates 'some_field', test: 'exclusion', in: [ 'if', 'while', 'class' ]
      
#### format

This test runs the field value against the supplied regular expression and passes if
a match is found.  The regexp is supplied as the property `with:`.  If no `with:` is 
supplied, every non-null value passes.  The default error message is "is invalid".

    it.validates 'some_field', 
      test: 'format'
      with: /^[a-zA-Z]+$/
      message: 'can only be letters'
      
#### inclusion

This test passes only if the field value is one of the values in the supplied array.
The array of values to test against are supplied as the `in:` property.  If no `in:`
is supplied, nothing passes.  The default error message is "is not included in the list".

    it.validates 'some_field', test: 'inclusion', in: ['latte', 'doppio', 'americano']
      
#### length

This test checks the length of field value against supplied values.  By default, it
checks the character length (that is, the value is split on the empty string and the
length of the array is checked).  Optionally, a different `tokenizer:` function can 
be supplied that takes one argument and returns an array.  For example, if instead of
checking the length in characters, you wanted to test the number of words, you could
supply a function that splits on whitespace:

    it.validates: 'some_field',
      test: 'length'
      tokenizer: (val) ->
        val.split(/\s+/)
      minimum:
        value: 3, 
        message: "must be at least 3 words"

The test must have at least one of three subtests supplied: `minimum:`, `maximum:`, or
`is:`.  Each of these subtests can either take a number value as an argument, or can
take a subvalidation object literal that supplies a `value:` to specify the 
comparison value and optionally a `message:` specific to that subtest's non-passage, 
and/or an `only_if:` or `unless:` guard on that subtest.  The example above shows the
subvalidation notation.  If you don't need a custom message, you can just do this:

    it.validates 'some_field', test: 'length', minimum: 3
      
Note, there are a couple of differences from Rails.  One, there are no `wrong_length:`,
`too_long:` or `too_short:` properties.  Instead, the messages for `is:`, `maximum:` and
`minimum:` are set by the `message:` property in a subvalidation, as shown above.
Also, there is no `in:` or `within:` property as there is no native Range type in 
JavaScript.  `in: 3..10` can be accomplished by using both a minimum and a maximum:

    it.validates 'some_field', test: 'length', minimum: 3, maximum: 10

The default error message for `minimum:` is "is too short (minimum is #{value} 
characters)".  The default error message for `maximum:` is "is too long (maximum is
 #{value} characters)".  The default error message for `is:` is
"is the wrong length (must be #{value} characters)".

#### numericality

This test checks that the value supplied is a number.  By default it makes sure the
value is a float.  You can force the test to make sure it is an integer by supplying
the property `only_integer: true`.  In both cases, the test is much stricter than the
simple JavaScript parseFloat or parseInt.  Leading or trailing whitespace is not 
allowed, nor is trailing non-numeric characters.  This is to try to match what Rails 
will do, so you don't pass on the client side just to have the server reject it.  
The default error message is "must be a number".  If `only_integer:` is set, the 
default error message is "must be an integer".

If the field passes the "is a number" or "is an integer" test, there are a number of
subtests that can be performed as well.  Each of the subtests below can be provided one
of two ways:  either the value is given as the value of the subtest's property:

    it.validates 'some_field', test: 'numericality', greater_than: 3
      
or as the `value:` property of a subvalidation object that can optionally supply a
`message:`, `only_if:`, and/or `unless:` property specific to that subtest:

    it.validates 'some_field',
      test: 'numericality'
      greater_than:
        value: 3
        message: 'must be bigger than 3'
        unless: 'someMethod'

Multiple subtests can be used together.  They are run in a fairly arbitrary order
(the order of the documentation should match execution order, but there is no
guarantee), and there is no short-circuiting (if one fails, the rest will still run).
The possible subtests, with default error messages, are:

* `greater_than:` "must be greater than #{value}"
* `greater_than_or_equal_to:` "must be greater than or equal to #{value}"
* `equal_to:` "must be equal to #{value}"
* `less_than:` "must be less than #{value}"
* `less_than_or_equal_to:` "must be less than or equal to #{value}"
* `odd:` "must be odd"
* `even:` "must be even"

#### presence

This tests whether the field is non-null and contains at least one non-whitespace
character.  Most other tests can not pass unless the field is non-blank, so there are 
two typical uses of this test:  one, presence is all you care about, or two, you want
a different error message if the field is blank versus if it is populated with an
invalid value.  In this second case, you will likely want to set `allow_blank:` on
the other, more specific test:

    it.validates 'some_field', test: 'presence'
    it.validates 'some_field', test: 'numericality', allow_blank: true
      
The default error message is "can't be empty".

#### absence

Yes, this is out of order alphabetically.  This is where it lands on the Rails guides too,
just after presence.  I'm just going for consistency here...

This tests the opposite of presences.  The test passes if the value is undefined,
null, the empty string or only whitespace.  The default error message is "must be blank".

#### custom

If you need a custom test not supplied by any of the pre-canned ones above, you simply
provide the test as method then give the method name as a string as the value of the
`test:` property.  The name of the method must not clash with any of the tests above or
else the pre-canned test will run instead.  If the name of the custom validation does
not match the name of a method on the model object, the error "custom validation is not
a function" will be thrown.  The method should take one argument (the value of the field
to be tested) and return a boolean-y value.  The default error message if the test 
runs and does not pass is "is invalid".  Here's an example of a naive test for divisible
by three:

    it = class MyModel extends MVCoffee.Model
      modByThree: (val) ->
        parseFloat(val) % 3 is 0

    it.validates 'some_field', test: 'modByThree', message: 'must be divisible by 3'
    

<a name="model-associations"></a>
### Associations

If you are using the [model store](#model-store) to cache data on the client, you can 
set associations between models using the macro methods `hasMany` and `belongsTo` (or
the snake-cased aliases `has_many` and `belongs_to`).

`hasMany` takes as an argument the snake-case name of the model that this model has 
many of and creates a method named the pluralized version of the other model.

    it = class MyModel extends MVCoffee.Model

    # creates the method "activities()" on MyModel instances    
    it.hasMany "activity"
    
`hasMany` takes optional arguments after the model name:

* `as:` sets the name of the method, overriding the default pluralized version of the 
model name

        # creates the method "passtimes()" that returns all associated activity models
        it.hasMany "activity", as: "passtimes"
    
* `foreignKey:` overrides the default foreign key name (this model name with "_id"
appended)

        it = class MyModel extends MVCoffee.Model
          modelName: "my_model"
          
        # would be "my_model_id" otherwise, now is "dude_id"
        it.hasMany "activity", foreignKey: 'dude_id'
        
* `order:` sorts the results on the values of the property supplied.  If the argument
is followed by the word `desc`, the sort will be descending.

        # does a descending sort on the field "position"
        it.hasMany "activity", order: "position desc"
        
`belongsTo` also takes as an argument the snake-case name of the model that this one
belongs to.  It creates a method matching that name that returns that model (if it is
in the model store).  

    it = class MyModel extends MVCoffee.Model
    
    # creates the method "owner()" on MyModel instances
    it.belongsTo "owner"

`belongsTo` accepts the options `as:` and `foreignKey:` as described above for `hasMany`.

<a name="model-store"></a>
### Model store and queries

The `ModelStore` is the object that holds all cached data on the client.  For the most
part you do not interact directly with the model store.  You just have to instantiate
an instance when your script first loads and register all of your models with the 
store.  Once your models are registered and server-supplied data has been loaded into 
the store, the models provide an interface for fetching data back out of the store.

#### Registering models

After all of your models have been defined and before controllers are fired, 
instantiate an instance of `ModelStore` and pass it a hash of snake-cased model
names to the constructor functions of the model classes.  For example, if you have
a namespace `MyProject` declared, you can do this:

    MyProject.dataStore = new MVCoffee.ModelStore
      user: MyProject.User
      activity: MyProject.Activity
     
If you are using Rails, this would go in your `master` file as recommended in the
[installation instructions](#installation) before creating the `ControllerManager`.

#### Loading data into models

The `ModelStore` provides a method, `load`, that takes an object and loads it into 
the store.  Any property in the store that matches a snake-cased name of a model is 
converted into `Model` objects and cached.  All non-matching properties are passed
through unmodified.  Most likely, this object is parsed JSON from the server.

For example, if we had the users and activities registered above, we can do this:

    # the var json is of this format:
    #   {"user":[{"id":1,"name":"Joe"},... ], "activity":[{"id":1,"user_id":1},...],
    #       "foo": 3} 
    fromServer = JSON.parse(json)

    data = myProject.dataStore.load(fromServer)
    # data is now in this format:
    #   {user:[MyProject.User({id:1,name:"Joe"}),...], 
    #     activity:[MyProject.Activity({id:1,user_id:1}),...],
    #     foo: 3}
    
At this point the store would hold all the user and activity data supplied by the json
string.

#### Querying

Once the data store has been loaded, we can do Rails-style querying on the models.

* `all()` returns all records of a model that is currently in the store:

        result = User.all()
        
  `all` can take an optional `order:` parameter:
  
        result = User.all order: "name"
  
* `find(id)` returns the one record matching the primary key id supplied.

        result = User.find(1)
        
#### Pluralizing model names

The model store tries to do its best to pluralize names for `hasMany` associations,
but English has a lot of irregularities.  If you find that it does not pluralize your
model names correctly, you can add pluralizations to the `MVCoffee.Pluralizer` class:

    MVCoffee.Pluralizer.addIrregular
      concerto: "concerti"
      
    concerto = class Concerto extends MVCoffee.Model
    concerto.belongsTo "composer"
    
    composer = class Composer extends MVCoffee.Model
    composer.hasMany "concerto"
    # This creates the method "concerti()" on Composer instances

<a name="views"></a>
## Views

Ironically, despite the name of the framework, there is no "view" functionality provided
by MVCoffee.  This is because there are already such good view templating packages
available.  If you are using Rails, the Sprockets provided JST works right out of the
box.

<a name="controllers"></a>
## Controllers

Controllers in MVCoffee are where you perform any response to user actions, convert
any html elements to jQuery UI widgets, and optionally take any actions needed to 
refresh the page should the data on it become stale.  MVCoffee allows there to be
zero to many controllers active at a time, and chooses which controllers to be active at
the moment based on the `id` tags found in the page.  With this approach, the
framework is not particularly well suited to the Single-Page Application (SPA) approach,
but does work quite well if your site takes advantage of Rails resource routing and
turbolinks to provide bookmarkable URL driven navigation through the site (an approach 
that I personally, as a website client, prefer.  Everyone's got their personal taste...).

To create a controller, simply extend `MVCoffee.Controller`, override the `onStart`
lifecycle method, and optionally override the `refresh` and `onStop` methods.  `onStart`
is where you will want to do all the kinds of things you would do at `$(document).ready` 
if you were using straight jQuery, such as:

* glean any embedded JSON on the page into models
* set up references to UI elements (buttons, forms, ...) with which you will need to
interact
* do any progressive enhancement (hide things that only display if JavaScript is
disabled
* attach event handlers
* convert html elements to jQuery UI widgets

Here's an example:

    class AddItem extends MVCoffee.Controller
      onStart: ->
        #=============================================================================
        # Glean info from the page
        
        item_json = $.parseJSON($("#item_json").html())
        @item = new Item(item_json)

        #=============================================================================
        # Hang on to element references we'll need
    
        @$errorsList = $('ul.errors');
        @$newItemForm = $('form#new_item');
        @$alternateItems = $('ul#alt-items');
    
        #=============================================================================
        # Progressive enhancement

        # Get rid of the buttons for resorting
        $(".reorder-buttons")
          .empty()
          .append('<span class="ui-icon ui-icon-arrowthick-2-n-s"></span>');  

        #=============================================================================
        # Set up events
    
        @$newItemForm.submit( =>
          @item.populate()
          # Do something here with @item.errors to display any errors to the user

          # Return whether or not @item is valid.  If you return false from the sumbit
          # method in jQuery, it suppresses the form from submitting to the server,
          # which is what we want: stay on this page so the user can see and fix the
          # errors.  If we return true, the submit is posted and we pass control to the
          # server.
          @item.isValid()
        )

        #=============================================================================
        # Convert html elements to jQuery UI
    
        @$alternateItems.sortable({
          start: (event, ui) =>
            # etc. etc.
          ,
          stop: (event, ui) =>
            # etc. etc.
        })
        
`onStop` is provided for completeness sake, but I have not personally come across a use
for it.  It is called as the controller is being unloaded, just before the refresh
timer and callbacks are disabled.  If you need to do any additional cleanup, this would
be the place.

<a name="refreshing"></a>
### Automatic refreshing

Any page on your site that contains data that may be modified on a different device
runs the risk of becoming stale.  Any page that has the chance to modify stale data
runs the risk of making your data inconsistent.  So wherever there is such a risk on
your site, it would be good practice to make the portion of the page that could be 
stale refresh itself every time the user returns to the page from another window or
browser tab, as well as periodically on a timer.  If the page is refreshing on a timer,
it would be good practice to disable the timer when the user goes to another window or
tab.  This is a common enough situation that MVCoffee handles all the `window.onFocus`
and `window.onBlur` and timer starting and stopping for you.  All you have to do is 
provide a callback that performs the refresh whenever it is triggered.

To provide a refresh callback, just override the `refresh` method in your controller:

      refresh: ->
        # Get all the alternates for this item over Ajax using a RESTful interface
        $.get('/items/' + @item.id + '/alternates',
          (data) =>
            # Do something with the data, check for success, what have you...
            
            # Use a Sprockets provided JST template to redraw the list of alternates
            if (data.alternates)
              @$alternateItems.empty()
              $.each(data.alternates, (index, alternate) => 
                 @$alternatesItems.append(JST['templates/alternate_list_item']({alternate: alternate, item: @item}))
              )
          ,
          'json')

Be default, `refresh` will be called once when the page regains focus after losing it,
plus once periodically as set by the property `timerInterval` (in millis).  The default
timer interval is one minute (60000 millis).  You can override this by setting the
`timerInterval` to a different value, or you can disable periodic refreshing entirely
to setting `timerInterval` to either null or zero.

<a name="controller-manager"></a>
### Registering Controllers with the Controller Manager

The final piece of the puzzle is the Controller Manager.  The Controller Manager handles
detecting what the current page is as identified by the `id` tag of the page's `<body>`
tag and deciding what controller to make active (as well as deactivating the 
controller for the prior page if appropriate).  In order to be able to do this, it needs
to know what controllers go with which page id's, and it needs to be started once upon the 
document being ready.  The way to do this is have a `manager.js.coffee` (or similiarly
named) file in your `app/assets/javascripts` directory that carries out these three steps:

* Instantiate an `MVCoffee.ControllerManager` object
* Add an instance of each controller to the controller manager, passing the `id` for
the page element that controller controls as an argument to the controller's constructor
* On jQuery's document ready, call `go()` on the controller manager

To make this concrete, here is a sample manager file adding controllers for adding and
editing items:

    # Set up the data source first

    controllerManager = new MVCoffee.ControllerManager
      new_item_page: NewItemController
      edit_item_page: EditItemController
      # More controllers follow
      ...

    $ ->
      controllerManager.go()

Note, this will work on a regular website in which every page load reloads everything,
JavaScripts and all.  It will create a new instance of a controller manager on every
page load and re-add all the controllers every time, then start the right controller for
that page.  Not terribly efficient, and kills the usefulness of the model store, 
but it will work.

On the other hand, if you are working with Rails, turbolinks does something really cool.
It gives you a hybrid between an SPA and the traditional full reload per page.  It does
fetch the html for the next page, but it does it over Ajax, keeping the JavaScript that
is running cached in the browser and still executing.  With turbolinks operating, the
initial setup of the controller manager will only happen once when the first page of your
site is visited, then all subsequent page loads within your site will only trigger the
document reader that fires the `go()` method.  This is how MVCoffee, when working with
Rails, helps give you the ability to maintain state on the client-side without having to 
go the full SPA approach.  **NOTE:** This only works if you have the 
[jQuery Turbolinks](https://github.com/kossnocorp/jquery.turbolinks)
gem in your project.  Otherwise turbolinks will cause jQuery not to fire the document
ready event and the controller manager will not be able to detect page changes.  Make
sure you use this gem!

<a name="controller-broadcast"></a>
### Broadcasting messages

What if an event in one controller needs to ripple through all other active controllers?
You can handle this by asking the controller manager to broadcasting a message to all
active controllers.  When controllers are registered with the controller manager, they
receive a reference back to the manager as the (aptly named) `manager` propert.  Inside
your controller, you can call `@manager.broadcast` and pass it the String name of the 
method to call (with optional arguments) on every controller currently active:

        @manager.broadcast "something_happened", args...

<a name="contributing"></a>
# Contributing

MVCoffee is fully open source, I welcome all collaboration and contribution to the 
project.  If you want to fix or add something, do the usual fork, branch and pull
request.  I'd prefer that all potential changes get brought up as "Issues" first.  You
never know, I could already be working on a fix or a feature and I'd hate to duplicate 
effort...

As with most projects, there are a lot of tests, in this case, some unit tests, some
more in the vein of black box tests where user interaction is crucial to determining
it works correctly.  They are discussed in depth in the accompanying file 
`HOW_TO_TEST.md`.

In short, you can run all the [jasmine-node](https://github.com/mhevery/jasmine-node)
tests on the command line:

    npm install # only need to do this once to install dependencies
    
    cake spec

The project also has a suite of [QUnit](http://qunitjs.com) tests that can be run 
by opening any html files in the `test/` directory in your browser.  Before you can run
the tests, you must run: 

    cake test-build
    
on the command line from the project root to compile the library from CoffeeScript to
JavaScript and to compile any ancillary CoffeeScript test files.
