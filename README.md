# MVCoffee

MVC: Model, View,... Coffee!

MVCoffee is (yet another) lightweight client-side MVC implementation for web
applications.  As the name implies, it is written in CoffeeScript.  It is designed to
support a specific approach to web development:

* It facilitates a hybrid between the Single Page Application (SPA) approach and 
old-school html serverd by the server, allowing for bookmarkable URL-driven navigation
through your site with enhanced client-side interactivity and Ajax-driven performance
improvements.  It is tailored to provide this especially well when used with 
[Ruby on Rails](http://rubyonrails.org) and the 
[jQuery Turbolinks](https://github.com/kossnocorp/jquery.turbolinks) gem.
* It allows a "progressive enhancement" approach in the off chance users have 
JavaScript disabled.
* It's expected that users may have the site running on multiple browsers (Safari, Chrome, 
Firefox, ...), or more likely on multiple devices (laptop, iPad, ...).  Persisting data
on the client therefore runs the risk of becoming stale and inconsistent.  The server
must be the master source for the data, and it should be easy to refresh potentially stale
data, both periodically and when a browser window regains focus.
MVCoffee handles knowing when to trigger a refresh, you just have to supply a callback.
* If the server is the master source of the data, it is ultimately responsible for
validation.  However, client-side validation improves performance and user experience,
so is beneficial.  Unfortunately, it violates DRY (don't repeat yourself).  It's 
duplicated effort to write the same validations on both client and server, and those 
can easily become out of sync.  MVCoffee tries to reduce the impact of this by providing
a model validation API that very closely mimics Rails' ActiveRecord validations.  In most 
cases it's a straight translation from Rails `validates` macro methods to JavaScript objects in MVCoffee.

<a name="dependencies"></a>
# Dependencies

* To use the already compiled and minified `.js` file in your project, the only 
dependency is [jQuery](http://jquery.com).
* To compile the code from source, your need [CoffeeScript](http://jashkenas.github.io/coffee-script/) which depends on [Node.js](http://nodejs.org).
* To minify the compiled JavaScript, you need to have [uglifyJS](https://npmjs.org/package/uglify-js) in your executable path.
* To locally compile markdown documentation files into html, you need [Markdown.pl](https://daringfireball.net/projects/markdown/) in your executable path.
* The unit tests depend on [jQuery](http://jquery.com) and [QUnit](http://qunitjs.com), but fetch them both from a CDN.  There are black box tests that depend on 
[Ruby on Rails](http://rubyonrails.org) and 
[jQuery Turbolinks](https://github.com/kossnocorp/jquery.turbolinks).  Also, for 
completeness sake there is a [nodeunit](https://github.com/caolan/nodeunit)
sanity check, just to see if the library loads as a node package.

<a name="usage"></a>
# Usage

<a name="installation"></a>
## Installation and Recommended Project Setup

To use MVCoffee, all you have to do is include the minified `.js` file in your project
add import it with a script tag before all of your controller and model declarations.

You can build it from source by running in the root directory of the project:

    cake minify
    
This will both compile the CoffeeScript to JavaScript and then minify it into the `lib`
directory.

If you are using Rails and the Sprockets driven asset pipeline, you can drop the 
minified `.js` file in your `vender/assets/javascripts` directory.  Preferably, instead of
the usual `//= require_tree .` that appears in a default Rails project setup, you would
control the order of loading in your `application.js` file like so:

    //= require mvcoffee.min
    //= require_directory ./models
    //= require_directory ./templates
    //= require_directory ./controllers
    //= require manager
    
Your models, views and controllers go in the `models`, `templates` and `controllers` 
directories, respectively (most likely `app/assets/javascripts/models`, etc.).  The
manager file will be discussed in the section ["Registering Controllers with the 
Controller Manager"](#controller-manager).

<a name="models"></a>
## Models

MVCoffee models are very lightweight.  They do not persist on the client, or save
themselves through a RESTful interface (although, I could see that being future feature).
They do populate themselves automatically from input forms using jQuery, and they do
validate themselves as long as you've provided the model with the correct metadata.

A model is defined by extending MVCoffee.Model, then supplying its metadata to various
predefined object properties.  Here's an example (you would probably namespace the
class name `Item`, but I'm keeping it simple for readability):

    class Item extends MVCoffee.Model
      modelName: 'item'

      fields: [
        {
          name: 'id'
        },
        {
          name: 'name',
          display: 'Item name',
          validates: [
            { test: "presence" }
          ]
        },
        {
          name: 'quantity_desired',
          type: 'integer',
          validates: [
            { test: "presence", unless: 'isUnlimited', message: 'must not be blank' },
            { 
              test: "numericality", 
              allow_blank: true,
              only_integer: true, 
              greater_than: { value: 0, message: 'must be greater than zero' },
            }
          ]
        },
        {
          name: 'unlimited',
          type: 'boolean'
        }
      ]

<a name="model-metadata"></a>
### Model Metadata

<a name="model-modelName"></a>
#### modelName

If you are using Rails, the `modelName` property is the lowercase name of the model in 
Rails-land that this client model mirrors.  This is only used for helping determine 
the ids of the input fields in a form.  The Rails `form_for` construct prepends this 
name and an underscore before all field names.  If you are not using Rails (or if you 
used the `form_tag` construct) and construct input field ids by hand, you should not 
supply this property.

<a name="model-fields"></a>
#### fields

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
    
becomes (inside the `fields` array described above):

      {
        name: 'first_name',
        validates: { test: 'presence' }
      }
    
All tests allow 5 optional "flag" properties:

* `message:`  let's you override the error message to be appended to the field name if 
the test doesn't pass.  If you do not want the field name as part of the message, you 
can set the field's `display` property to the empty string.

          validates: { test: 'presence', message: 'must not be blank' }

* `allow_null:`  if true causes the test not to be executed if the field is either 
undefined or null.  Note the different spelling from Rails, as in JavaScript it's "null" 
instead of "nil".

          validates: { test: 'numericality', allow_null: true }

* `allow_blank:`  causes the test not to be executed if the field is undefined, null,
the empty string or only whitespace.

          validates: { test: 'numericality', allow_blank: true }

* `only_if:`  causes the test to only be executed if the method named as the value for
`only_if:` returns true (or any truthy value).  This is similar to the `if:` symbol 
in Rails, but is named `only_if:` since "if" is a reserved word in JavaScript and it's 
not ideal to use it as a property name.  The value for `only_if:` must be a string that 
is the name of a method on the model.  

          validates: { test: 'presence', only_id: "termsAccepted" }
      
        ...
    
        termsAccepted: ->
          # Some nifty calculation that results in a boolean
      
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

      validates: { test: 'acceptance', accept: true }
      
#### confirmation

This test checks that the field it's associated with matches a field with the same name
as this one suffixed with "`_confirmation`".  Unless `allow_blank:` is set, it requires
that the two fields are populated.  The default error message is "doesn't match 
confirmation".

    {
      name: 'password',
      validates: { test: 'confirmation' }
    },
    {
      name: 'password_confirmation'
    }

#### email

This is a bonus test not supplied in Rails.  It checks the field against a fairly
nasty regular expression that I believe captures the legal format of an email 
address.  No guarantees, of course.  The default error message is "must be a valid
email address".

      validates: { test: 'email' }
      
#### exclusion

This test passes only if the field value is not in the supplied array of values.
The array of values to test against are supplied as the `in:` property.  If no `in:` is
supplied, every non-blank value passes.  The default error message is "is reserved".

      validates: { test: 'exclusion', in: [ 'if', 'while', 'class' ] }
      
#### format

This test runs the field value against the supplied regular expression and passes if
a match is found.  The regexp is supplied as the property `with:`.  If no `with:` is 
supplied, every non-null value passes.  The default error message is "is invalid".

      validates: { 
        test: 'format', 
        with: /^[a-zA-Z]+$/,
        message: 'can only be letters'
      }
      
#### inclusion

This test passes only if the field value is one of the values in the supplied array.
The array of values to test against are supplied as the `in:` property.  If no `in:`
is supplied, nothing passes.  The default error message is "is not included in the list".

      validates: { test: 'inclusion', in: ['latte', 'doppio', 'americano'] }
      
#### length

This test checks the length of field value against supplied values.  By default, it
checks the character length (that is, the value is split on the empty string and the
length of the array is checked).  Optionally, a different `tokenizer:` function can 
be supplied that takes one argument and returns an array.  For example, if instead of
checking the length in characters, you wanted to test the number of words, you could
supply a function that splits on whitespace:

      validates: { 
        test: 'length', 
        tokenizer: (val) ->
          return val.split(/\s+/);
        ,
        minimum: { 
          value: 3, 
          message: "must be at least 3 words"
        }
      }

The test must have at least one of three subtests supplied: `minimum:`, `maximum:`, or
`is:`.  Each of these subtests can either take a number value as an argument, or can
take a subvalidation object literal that supplies a `value:` to specify the 
comparison value and optionally a `message:` specific to that subtest's non-passage, 
and/or an `only_if:` or `unless:` guard on that subtest.  The example above shows the
subvalidation notation.  If you don't need a custom message, you can just do this:

      validates: { test: 'length', minimum: 3 }
      
Note, there are a couple of differences from Rails.  One, there are no `wrong_length:`,
`too_long:` or `too_short:` properties.  Instead, the messages for `is:`, `maximum:` and
`minimum:` are set by the `message:` property in a subvalidation, as shown above.
Also, there is no `in:` or `within:` property as there is no native Range type in 
JavaScript.  `in: 3..10` can be accomplished by using both a minimum and a maximum:

      validates: { test: 'length', minimum: 3, maximum: 10 }

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

      validates: { test: 'numericality', greater_than: 3 }
      
or as the `value:` property of a subvalidation object that can optionally supply a
`message:`, `only_if:`, and/or `unless:` property specific to that subtest:

      validates: {
        test: 'numericality',
        greater_than: {
          value: 3,
          message: 'must be bigger than 3',
          unless: 'someMethod'
        }
      }

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

      validates: [
        { test: 'presence' },
        { test: 'numericality', allow_blank: true }
      ]
      
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

      validates: { test: 'modByThree', message: 'must be divisible by 3' }
      
    ...
    
    modByThree: (val) ->
      parseFloat(val) % 3 is 0
      
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
refresh the page should the data on it become stale.  MVCoffee expects there to be
at most one controller active at a time, and chooses which controller to be active at
the moment based on the `id` of the page's `<body>` tag.  With this approach, the
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

      refresh: =>
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
the page that controller controls as an argument to the controller's constructor
* On jQuery's document ready, call `go()` on the controller manager

To make this concrete, here is a sample manager file adding controllers for adding and
editing items:

    controllerManager = new MVCoffee.ControllerManager()

    controllerManager.addController(new NewItemController("new_item_page"))
    controllerManager.addController(new EditItemController("edit_item_page"))
    # More controllers follow
    ...

    $ ->
      controllerManager.go()

Note, this will work on a regular website in which every page load reloads everything,
JavaScripts and all.  It will create a new instance of a controller manager on every
page load and re-add all the controllers every time, then start the right controller for
that page.  Not terribly efficient, but it will work.

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

In short, the project has a suite of [QUnit](http://qunitjs.com) tests that can be run 
by opening any html files in the `test/` directory in your browser.  Before you can run
the tests, you must run: 

    cake test
    
on the command line from the project root to compile the library from CoffeeScript to
JavaScript and to compile any ancillary CoffeeScript test files.
