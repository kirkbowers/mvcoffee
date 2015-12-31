# MVCoffee

Model, View.... Coffee!

MVCoffee is (yet another) lightweight client-side MVC implementation for web
applications.  As the name implies, it is written in CoffeeScript.  

Do we really need another MVC framework for the browser?  Maybe not, but this one does have a very specific purpose.  It is designed to integrate tightly with [Rails 4](http://rubyonrails.org) and take full advantage of Turbolinks, particularly when using the [jQuery Turbolinks](https://github.com/kossnocorp/jquery.turbolinks) gem.  Here are some of MVCoffee's benefits:

* **Rails-like Models for client-side caching and validating**  It's quite beneficial to 
represent the data of an application on the client.  Round trips can be avoided by performing validation on the client and by caching information that hasn't changed.  Unfortunately, creating a copy of the model layer violates DRY (don't repeat yourself).  MVCoffee eases the pain of this duplication of effort by mimicking Rails style model declarations as closely as possible in CoffeeScript.  Model associations and validations are declared in MVCoffee using the familiar class macro methods `has_many`, `belongs_to` and `validates`.  Yes, class macro methods, or at least a close approximation, in CoffeeScript!
* **Filled in holes in Turbolinks**  Turbolinks makes it possible to have the benefits of client data caching previously only possible in a Single Page Application (SPA) while allowing the convenience to end-users of URL based navigation.   That is, most of the time, so long as the user clicked on a link on one of your pages.  It breaks (your cache gets wiped out) when a full page load occurs.  Out of the box, full page loads occur when a form is submitted, a button is clicked (because it is a form under the hood), or a generic redirect is issued.  MVCoffee automagically intercepts form submissions and performs them over ajax for you and issues redirects on the client side without clobbering the cache.  You're saved the effort and coding of manually performing validations and invoking ajax upon form submissions.
* **Automatic refresh of potentially stale data**  These days, your application can be running in several browser windows simultaneously, or even multiple devices (laptop, tablet, phone, etc.) at one time.  If the user changes the data in one window, then returns to another window, that second window is operating with stale data.  MVCoffee automates doing the right thing in this situation.  All you have to do is provide the callbacks for the refresh life cycle (start, pause, resume, stop) and what the refresh policy should be (when the window regains focus, on a timer, or both), and MVCoffee takes care of firing your policy for you.  This can also be used to update UI elements (like a clock) that may have frozen when the user was viewing a different window.

<a name="whats-new"></a>
# What's new in 1.0

MVCoffee is finally stable enough (hopefully) to be given a "1" in the front of the version number.  The format of the JSON expected from the server was strongly refactored in version 1.0, so <= 0.3 version JSON will cause version 1 to gack.  This shouldn't be a problem for two reasons.  One, the new JSON format must contain a version number in it.  If it is missing, or if it contains a number earlier than expected by the Model Store, an exception is thrown.  Two, there is now a Rails gem [mvcoffee-rails](https://github.com/kirkbowers/mvcoffee-rails) that provides an API to generate the expected JSON format and includes the matching mvcoffee.js into your rails project.  Except in the extreme off chance that you are using this outside of Rails, you should never have to concern yourself with the JSON format or build it manually.

Also, version 1.0 fixes an incompatibility between iOS Safari and desktop browsers.  `resume` and `refresh` life cycle events should fire correctly in iOS now.

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


# Documentation

This framework has become feature rich enough that it is too cumbersome to capture it all in a single README file.  Plus, now that there are complementary Ruby gems, it makes sense to document all the interacting components in one place.  Full documentation is provided at:

[mvcoffee.org](http://mvcoffee.org)


<a name="contributing"></a>
# Contributing

MVCoffee is fully open source, I welcome all collaboration and contribution to the 
project.  If you want to fix or add something, do the usual fork, branch and pull
request.  I'd prefer that all potential changes get brought up as "Issues" first.  And/or [contact me directly](http://mvcoffee.org/contact).  You
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
