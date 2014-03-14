## Documentation
[http://stoodder.github.io/falconjs/](http://stoodder.github.io/falconjs/)

## Change Log
###v0.10.0
**Highlights**
* Added Falcon.Adapter for splitting out dependencies on how we transmit, respond to, and receive data form a backend data source.
* Fully Compatible with Knockout 3.1
* New Falcon.Object methods: listenTo and stopListening
* New Falcon.Model methods: increment, decrement
* New Falcon.Collection methods: all, set, merge, replace

**Breaking Changes**
* You must now include the falcon.jquery_adapater.js to support ajax requests with jQuery as Falcon's dependency on jQuery has been completely removed in version 0.10.0.
* Model and Collection constructors will now throw an error if the parent object isn't null/undefined or a model

**TODO**
* Add support for Falcon.Collection in the without() method (remove all models from the resultant collection that are in the given collection)
* add generate binding and Falcon.register for dynamically creating views

**Enhancements**
* Convert Build process to Grunt.js
* Added id override to model makeUrl
* Add 'all' method to collections
* Added 'merge' method to collections
* Added 'replace' method to collections
* Add 'increment' and 'decrement' to models
* Add 'listenTo' and 'stopListening' to Falcon.Object
* Converted unit tests to Jasmine
* Removing the usages of unwrap where not necessary. Models should carry over by reference, not duplication
* Reworked the initialization process
* Removed jQuery for DOM listening/manipulation
* Added base adapter class
* Added jQuery adapter to handle all ajax handling and removed the rest of the jQuery calls from Falcon
* Add 'set' method to collections (sets all values for a key to each model in the collection)
* Divided fill method into separate methods for each type (reverse rolls)
* Support for Knockout 3.1

**Bugs Fixed**
* Fixed reference overwritting on colleciton merge method.
* Fixed length() on collection chains


###v0.8.0
* Separated Knockout source code from Falcon
* Updated Falcon to work with Knockout 3
* Added Falcon.getBinding() method
* Allowed Falcon.addBinding() to take just a key and function (as opposed to a key and an object). If a function is given, it's set as the new binding's 'update' key
* Fixed bug in makeUrl when setting baseApiUrl and baseTemplateUrl to "/"

## For The Future
### 0.11.0
* Add method support for 'obervables' and 'defaults' (rather than dictionary defintion)
* Add exec binding
* Cleanup/Redo binding tests
* Pass fill options through recursive calls to the fill methods
