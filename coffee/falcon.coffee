@Falcon = Falcon = new class extends FalconObject
	GET: 'GET'
	POST: 'POST'
	PUT: 'PUT'
	DELETE: 'DELETE'
	REQUEST_TYPES: ['GET', 'POST', 'PUT', 'DELETE']

	'Object': FalconObject
	'Model': FalconModel
	'Collection': FalconCollection
	'View': FalconView
	'DataAdapter': FalconDataAdapter
	'TemplateAdapter': FalconTemplateAdapter

	#--------------------------------------------------------
	# Attribute: Falcon.version
	#	The current version of Falcon
	#
	# Type: _(String)_
	#--------------------------------------------------------
	version: "1.0.0rc1"

	#--------------------------------------------------------
	# Attribute: Falcon.applicationElement
	#	The default element to apply the bindings to if none is specified in Falcon.apply()
	#
	# Type: _(String)_
	#--------------------------------------------------------
	applicationElement: "body"

	#--------------------------------------------------------
	# Attribute: Falcon.baseApiUrl
	#	The base API url prefix to be added to Models and Collections when makeUrl is called
	#
	# Type: _(String)_
	#--------------------------------------------------------
	baseApiUrl: ""

	#--------------------------------------------------------
	# Attribute: Falcon.baseTemplateUrl
	#	The base template url prefix to be added to Views when makeUrl is called
	#	with a remote uri (rather than an element id)
	#
	# Type: _(String)_
	#--------------------------------------------------------
	baseTemplateUrl: ""

	#--------------------------------------------------------
	# Attribute: Falcon.deferEvaluation
	#	Should our computed observables use deferedEvaluation?
	#
	# Type: _(String)_
	#--------------------------------------------------------
	deferEvaluation: true

	#--------------------------------------------------------
	# Attribute: Falcon.dataAdapter
	#	The adapater instance for syncing data between the
	#	front end and data store
	#
	# Type: _(Falcon.DataAdapter)_
	#--------------------------------------------------------
	dataAdapter: new FalconDataAdapter

	#--------------------------------------------------------
	# Attribute: Falcon.templateAdapter
	#	The object used to load and cache templates
	#
	# Type: _(Falcon.TemplateLoader)_
	#--------------------------------------------------------
	templateAdapter: new FalconTemplateAdapter

	#--------------------------------------------------------
	# Method: Falcon.ready(callback)
	#	Methods to call when the document is loaded, or right away
	#	if the document is already loaded
	#
	# Arguments:
	#	**callback** _(Function)_ - Callback method to trigger after document loads
	#--------------------------------------------------------
	ready: do ->
		#Define the '_ready' method.
		_ready_callbacks = []
		_ready = (callback) ->
			_ready_callbacks.push( callback ) if isFunction( callback )
		#END _ready

		_domLoadedEvent = ->
			_ready = (callback) ->
				callback() if isFunction( callback )
			#END _ready re-assignment

			callback() for callback in _ready_callbacks
			_ready_callbacks = null
		#END _domLoadedEvent

		if document.addEventListener
			document.addEventListener "DOMContentLoaded", _DOMContentLoaded = ->
				_domLoadedEvent()
				document.removeEventListener( "DOMContentLoaded", _DOMContentLoaded )
			#END addEventListener
		else
			original_onreadystatechange = document.onreadystatechange
			document.onreadystatechange = ->
				if document.readyState is "complete"
					_domLoadedEvent()
					document.onreadystatechange = original_onreadystatechange
				#END if

				original_onreadystatechange.apply(@, arguments) if isFunction( original_onreadystatechange )
			#END onreadystatechange
		#END if

		return -> _ready(arguments...)
	#END do

	#--------------------------------------------------------
	# Method: Falcon.apply
	#	The method to initialize a Falcon application and apply its bindings against an initial view.
	#
	# Arguments:
	#	**root** _(Falcon.View|ko.observable)_ - A view or an observable containing a view to be 
	#											 applied to the application element
	#	**element** _(String|DOMElement)_ - The element to intialize the application in
	#	**callback** _(Function)_ - Method called after the bindings have been initialized and applied
	#
	# Returns:
	#	_(Falcon)_ - This Instance
	#--------------------------------------------------------
	apply: (root, element, callback) ->
		[callback, element] = [element, null] if isFunction( element )
		[callback, root] = [root, null] if isFunction( root ) and not ko.isObservable(root) and not isFunction( callback )

		element ?= Falcon.applicationElement

		Falcon.ready ->
			Falcon.templateAdapter.cacheAllTemplates()
			
			unless isElement( element )
				element = "" unless isString( element )
				element = if isEmpty( element ) then "body" else trim( element )
				element = document.querySelectorAll(element)[0] ? document.body
			#END unless

			#Apply the app
			if root?
				ko.applyBindingAccessorsToNode(element, {view: -> root})
			else
				ko.applyBindings({}, element)
			#END if

			#Trigger any callback to notify the application that
			#the app has been initialized and the bindings are applied.
			callback() if isFunction( callback )
		#END _ready

		return Falcon
	#END apply

	#--------------------------------------------------------
	# Method: Falcon.isModel()
	#	Method used to test if an object is a Falcon Model
	#
	# Arguments:
	#	**object** _(mixed)_ -  The object to test
	#
	# Returns:
	#	_(Boolean)_ - Is the object a model?
	#--------------------------------------------------------
	isModel: (object) -> 
		return object? and object instanceof Falcon.Model
	#END isModel

	#--------------------------------------------------------
	# Method: Falcon.isCollection()
	#	Method used to test if an object is a Falcon Collection
	#
	# Arguments:
	#	**object** _(mixed)_ -  The object to test
	#
	# Returns:
	#	_(Boolean)_ - Is the object a colleciton?
	#--------------------------------------------------------
	isCollection: (object) -> 
		return object? and object instanceof Falcon.Collection
	#END isCollection

	#--------------------------------------------------------
	# Method: Falcon.isView()
	#	Method used to test if an object is a Falcon View
	#
	# Arguments:
	#	**object** _(mixed)_ -  The object to test
	#
	# Returns:
	#	_(Boolean)_ - Is the object a view?
	#--------------------------------------------------------
	isView: (object) -> 
		return object? and object instanceof Falcon.View
	#END isView

	#--------------------------------------------------------
	# Method: Falcon.isDataObject()
	#	Method used to test if an object is a Falcon Model or Collection
	#
	# Arguments:
	#	**object** _(mixed)_ -  The object to test
	#
	# Returns:
	#	_(Boolean)_ - Is the object a falcon data object?
	#--------------------------------------------------------
	isDataObject: (object) -> 
		return object? and ( object instanceof Falcon.Model or object instanceof Falcon.Collection )
	#END isDataObject

	#--------------------------------------------------------
	# Method: Falcon.isAdapter()
	#	Method used to test if an object is a Falcon Adapter
	#
	# Arguments:
	#	**object** _(mixed)_ -  The object to test
	#
	# Returns:
	#	_(Boolean)_ - Is the object a falcon adapter?
	#--------------------------------------------------------
	isAdapter: (object) -> 
		return object? and object instanceof Falcon.DataAdapter
	#END isAdapter

	#--------------------------------------------------------
	# Method: Falcon.isFalconObject()
	#	Method used to test if an object is a Falcon Specific 
	#	Object (View, Model, or Collection).
	#
	# Arguments:
	#	**object** _(mixed)_ -  The object to test
	#
	# Returns:
	#	_(Boolean)_ - Is the object a falcon object?
	#--------------------------------------------------------
	isFalconObject: (object) ->
		return object? and ( object instanceof Falcon.Object )
	#END isFalconObjext

	#--------------------------------------------------------
	# Method: Falcon.addBinding()
	#	Method used to add a new binding for Knockout
	#
	# Arguments:
	#	**name** _(String)_ -  The binding name
	#	**definition** _(Object)_ -  The binding definition
	#	**allowVirtual** _(Boolean)_ - Should this binding be accessible using ko comments
	#
	# Returns:
	#	_(Object)_ - The binding definition
	#--------------------------------------------------------
	addBinding: (name, definition, allowVirtual) ->
		[definition, allowVirtual] = [allowVirtual, definition] if isBoolean( definition )
		definition = {update: definition} if isFunction( definition )
		ko.bindingHandlers[name] = definition
		ko.virtualElements.allowedBindings[name] = true if allowVirtual
		return ko.bindingHandlers[name]
	#END addBinding

	#--------------------------------------------------------
	# Method: Falcon.getBinding()
	#	Method used to consitently fetch a binding defintion from Knockout
	#
	# Arguments:
	#	**name** _(String)_ -  The binding name
	#
	# Returns:
	#	_(Object)_ - The binding definition
	#--------------------------------------------------------
	getBinding: (name) -> ko.bindingHandlers[name]

	#--------------------------------------------------------
	# Method: Falcon.addComponent(tag_name, defintion)
	#	Method used to define a component
	#
	# Arguments:
	#	**tag_name** _(String)_ -  The tag name of your new component
	#	**view_defintion** _(Falcon.View)_ - The falcon view defintion (not an instance)
	#
	# Returns:
	#	_(Object)_ - The component definition
	#--------------------------------------------------------
	addComponent: (tag_name, view_defintion) ->
		ko.components.register(tag_name, view_defintion)
	#END addComponent

	#--------------------------------------------------------
	# Method: Falcon.onDispose(element, callback)
	#	Event listenet method to assign a callback for when a node is diposed
	#
	# Arguments:
	#	**element** _(Node)_ -  The Element or Virtual Node to listen to
	#	**callback&& _(Function)_ - The callback function to trigger when this node is removed
	#
	# Returns:
	#	_(Object)_ - The dispose listener
	#--------------------------------------------------------
	onDispose: (element, callback) ->
		ko.utils.domNodeDisposal.addDisposeCallback(element, callback)
	#END onDispose
#END Falcon

