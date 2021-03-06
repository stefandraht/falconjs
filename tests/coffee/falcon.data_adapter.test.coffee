describe "Falcon.DataAdapter", ->
	describe "extend", ->
	#END describe
	
	describe "resolveRequestType", ->
		adapter = new Falcon.DataAdapter
		data_object = new Falcon.Model
		options = {}
		context = null

		it "Should return GET if type isn't a string", ->
			expect( adapter.resolveRequestType(data_object, null, options, context) ).toBe( Falcon.GET )
			expect( adapter.resolveRequestType(data_object, 123, options, context) ).toBe( Falcon.GET )
		#END it

		it "Should return GET is type isn't GET, PUT, POST, DELETE", ->
			expect( adapter.resolveRequestType(data_object, "HELLO WORLD", options, context) ).toBe( Falcon.GET )
		#END it

		it "Should cast get, put, post, delete (lower case) to their proper forms", ->
			expect( adapter.resolveRequestType(data_object, "get", options, context) ).toBe( Falcon.GET )
			expect( adapter.resolveRequestType(data_object, "put", options, context) ).toBe( Falcon.PUT )
			expect( adapter.resolveRequestType(data_object, "post", options, context) ).toBe( Falcon.POST )
			expect( adapter.resolveRequestType(data_object, "delete", options, context) ).toBe( Falcon.DELETE )
		#END it

		it "Should ignore whitespace", ->
			expect( adapter.resolveRequestType(data_object, "  GET  ", options, context) ).toBe( Falcon.GET )
			expect( adapter.resolveRequestType(data_object, "  PUT  ", options, context) ).toBe( Falcon.PUT )
			expect( adapter.resolveRequestType(data_object, "  POST  ", options, context) ).toBe( Falcon.POST )
			expect( adapter.resolveRequestType(data_object, "  DELETE  ", options, context) ).toBe( Falcon.DELETE )
		#END it
	#END describe

	describe "resovleContext", ->
		adapter = new Falcon.DataAdapter
		data_object = new Falcon.Model(id: 1)
		type = Falcon.GET
		options = {context: {id: 2}}
		context = {id: 3}

		it "Should resolve the context properly if given", ->
			expect( adapter.resolveContext(data_object, type, options, context) ).toBe( context )
		#END it

		it "Should fallback on the options context if no context is given", ->
			expect( adapter.resolveContext(data_object, type, options, null) ).toBe( options.context )
			expect( adapter.resolveContext(data_object, type, options) ).toBe( options.context )
		#END it

		it "Should fall back on the data_object as context if no context or options.context is given", ->
			expect( adapter.resolveContext(data_object, type, {}, null) ).toBe( data_object )
			expect( adapter.resolveContext(data_object, type, {}) ).toBe( data_object )
		#END it
	#END describe

	describe "standardizeOptions", ->
		adapter = new Falcon.DataAdapter
		parent = new Falcon.Model
		data_object = new Falcon.Model({id: 1}, parent)
		type = Falcon.GET
		context = {id: 3}

		beforeEach ->
			spyOn( adapter, 'resolveUrl' ).and.callThrough()
			spyOn( adapter, 'serializeData' ).and.callThrough()
		#END beforeEach

		it "Should present standard options if nothing is passed in", ->
			ret = adapter.standardizeOptions(data_object, type, null, context)
			
			expect( ret['id'] ).not.toBeDefined()
			expect( ret['success'] ).toEqual( jasmine.any(Function) )
			expect( ret['complete'] ).toEqual( jasmine.any(Function) )
			expect( ret['error'] ).toEqual( jasmine.any(Function) )
			expect( ret['parent'] ).toEqual( data_object.parent )
			expect( ret['url'] ).toEqual( jasmine.any(String) )
			expect( ret['data'] ).toBeNull()
			expect( ret['attributes'] ).toBeNull()
			expect( ret['fill_options'] ).toBeNull()

			expect( adapter.resolveUrl.calls.count() ).toBe( 1 )
			expect( adapter.resolveUrl ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )

			expect( adapter.serializeData.calls.count() ).toBe( 1 )
			expect( adapter.serializeData ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
		#END it

		it "Should maintain options that are passed in", ->
			id = 'hello_world'
			success = (->)
			complete = (->)
			error = (->)
			parent = null
			attributes = ['id', 'hello']
			url = 'http://www.google.com'
			data = {'hello': 'world'}
			attributes = ['id', 'hello']
			fill_options = {'method': 'append'}

			options = {id, success, complete, error, parent, attributes, url, data, attributes, fill_options}

			ret = adapter.standardizeOptions(data_object, type, options, context)

			expect( ret['id'] ).toBe( options.id )
			expect( ret['success'] ).toBe( options.success )
			expect( ret['complete'] ).toBe( options.complete )
			expect( ret['error'] ).toBe( options.error )
			expect( ret['parent'] ).toBe( options.parent )
			expect( ret['url'] ).toBe( options.url )
			expect( ret['data'] ).toBe( options.data )
			expect( ret['attributes'] ).toBe( options.attributes )
			expect( ret['fill_options'] ).toBe( options.fill_options )

			expect( adapter.resolveUrl.calls.count() ).toBe( 1 )
			expect( adapter.resolveUrl ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )

			expect( adapter.serializeData.calls.count() ).toBe( 1 )
			expect( adapter.serializeData ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )

			#The return object should not be the same object as the options
			expect( ret ).not.toBe( options )

			#Make sure the options haven't changed at all
			expect( options ).toEqual({id, success, complete, error, parent, attributes, url, data, attributes, fill_options})
		#END it

		it "Should assign a function to the complete attribute of the options", ->
			options = (->)
			
			ret = adapter.standardizeOptions(data_object, type, options, context)

			expect( ret['id'] ).not.toBeDefined()
			expect( ret['success'] ).toEqual( jasmine.any(Function) )
			expect( ret['complete'] ).toEqual( options )
			expect( ret['error'] ).toEqual( jasmine.any(Function) )
			expect( ret['parent'] ).toEqual( data_object.parent )
			expect( ret['attributes'] ).toBeNull()
			expect( ret['url'] ).toEqual( jasmine.any(String) )
			expect( ret['data'] ).toBeNull()
			expect( ret['fill_options'] ).toBeNull()

			expect( adapter.resolveUrl.calls.count() ).toBe( 1 )
			expect( adapter.resolveUrl ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )

			expect( adapter.serializeData.calls.count() ).toBe( 1 )
			expect( adapter.serializeData ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
		#END it

		it "Should split a string into an array of attributes", ->
			options = "id,hello_world,title"
			
			ret = adapter.standardizeOptions(data_object, type, options, context)

			expect( ret['id'] ).not.toBeDefined()
			expect( ret['success'] ).toEqual( jasmine.any(Function) )
			expect( ret['complete'] ).toEqual( jasmine.any(Function) )
			expect( ret['error'] ).toEqual( jasmine.any(Function) )
			expect( ret['parent'] ).toEqual( data_object.parent )
			expect( ret['attributes'] ).toEqual( ['id','hello_world','title'] )
			expect( ret['url'] ).toEqual( jasmine.any(String) )
			expect( ret['data'] ).toBeNull()
			expect( ret['fill_options'] ).toBeNull()

			expect( adapter.resolveUrl.calls.count() ).toBe( 1 )
			expect( adapter.resolveUrl ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )

			expect( adapter.serializeData.calls.count() ).toBe( 1 )
			expect( adapter.serializeData ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
		#END it

		it "Should pass through an array into the attrbutes attribute of the options", ->
			options = ['id','hello_world','title']
			
			ret = adapter.standardizeOptions(data_object, type, options, context)

			expect( ret['id'] ).not.toBeDefined()
			expect( ret['success'] ).toEqual( jasmine.any(Function) )
			expect( ret['complete'] ).toEqual( jasmine.any(Function) )
			expect( ret['error'] ).toEqual( jasmine.any(Function) )
			expect( ret['parent'] ).toEqual( data_object.parent )
			expect( ret['attributes'] ).toEqual( options )
			expect( ret['url'] ).toEqual( jasmine.any(String) )
			expect( ret['data'] ).toBeNull()
			expect( ret['fill_options'] ).toBeNull()

			expect( adapter.resolveUrl.calls.count() ).toBe( 1 )
			expect( adapter.resolveUrl ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )

			expect( adapter.serializeData.calls.count() ).toBe( 1 )
			expect( adapter.serializeData ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
		#END it

		it "Should allow for attributes to be an object", ->
			attributes = {'id': true, 'model_1': {'id': true}}
			options = {attributes}

			ret = adapter.standardizeOptions(data_object, type, options, context)

			expect( ret['id'] ).not.toBeDefined()
			expect( ret['success'] ).toEqual( jasmine.any(Function) )
			expect( ret['complete'] ).toEqual( jasmine.any(Function) )
			expect( ret['error'] ).toEqual( jasmine.any(Function) )
			expect( ret['parent'] ).toEqual( data_object.parent )
			expect( ret['attributes'] ).toEqual( attributes )
			expect( ret['url'] ).toEqual( jasmine.any(String) )
			expect( ret['data'] ).toBeNull()
			expect( ret['fill_options'] ).toBeNull()

			expect( adapter.resolveUrl.calls.count() ).toBe( 1 )
			expect( adapter.resolveUrl ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )

			expect( adapter.serializeData.calls.count() ).toBe( 1 )
			expect( adapter.serializeData ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )

			#The return object should not be the same object as the options
			expect( ret ).not.toBe( options )

			#Make sure the options haven't changed at all
			expect( options ).toEqual({attributes})
		#END it
	#END describe

	describe "resolveUrl", ->
		adapter = new Falcon.DataAdapter
		data_object = new Falcon.Model({id: 1})
		context = {id: 3}
		options = {
			parent: new Falcon.Model
		}

		beforeEach ->
			spyOn( data_object, 'makeUrl' ).and.returnValue("http://www.falconjs.com")
		#END beforeEach

		it "Should call the data objects resolveUrl method", ->
			ret = adapter.resolveUrl(data_object, Falcon.GET, options, context)

			expect( data_object.makeUrl.calls.count() ).toBe(1)
			expect( ret ).toBe("http://www.falconjs.com")
		#END it

		it "Should use the options' url if one is available", ->
			options.url = "http://www.google.com"

			ret = adapter.resolveUrl(data_object, Falcon.GET, options, context)

			expect( data_object.makeUrl ).not.toHaveBeenCalled()
			expect( ret ).toBe("http://www.google.com")
		#END it
	#END describe

	describe "makeBaseUrl", ->
		adapter = new Falcon.DataAdapter
		data_object = new Falcon.Model({id: 1, endpoint: "a"})
		context = data_object
		options = null
		baseApiUrl = null

		beforeEach ->
			baseApiUrl = Falcon.baseApiUrl
			Falcon.baseApiUrl = null
			options = {}
		#END beforeEach

		afterEach ->
			Falcon.baseApiUrl = baseApiUrl
		#END afterEach

		it "Should generate a base url properly without a parent with GET", ->
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("/")
		#END it

		it "Should generate a base url properly without a parent with POST", ->
			ret = adapter.makeBaseUrl( data_object, Falcon.POST, options, context)
			expect( ret ).toBe("/")
		#END it

		it "Should generate a base url properly without a parent with PUT", ->
			ret = adapter.makeBaseUrl( data_object, Falcon.PUT, options, context)
			expect( ret ).toBe("/")
		#END it

		it "Should generate a base url properly without a parent with DELETE", ->
			ret = adapter.makeBaseUrl( data_object, Falcon.DELETE, options, context)
			expect( ret ).toBe("/")
		#END it


		it "Should generate a base url properly with a single parent with GET", ->
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"})
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("/b/2/")
		#END it

		it "Should generate a base url properly with a single parent with POST", ->
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"})
			ret = adapter.makeBaseUrl( data_object, Falcon.POST, options, context)
			expect( ret ).toBe("/b/2/")
		#END it

		it "Should generate a base url properly with a single parent with PUT", ->
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"})
			ret = adapter.makeBaseUrl( data_object, Falcon.PUT, options, context)
			expect( ret ).toBe("/b/2/")
		#END it

		it "Should generate a base url properly with a single parent with DELETE", ->
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"})
			ret = adapter.makeBaseUrl( data_object, Falcon.DELETE, options, context)
			expect( ret ).toBe("/b/2/")
		#END it


		it "Should generate a url properly with more than one parent with GET", ->
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("/c/3/b/2/")
		#END it

		it "Should generate a url properly with more than one parent with POSt", ->
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, "POSt", options, context)
			expect( ret ).toBe("/c/3/b/2/")
		#END it

		it "Should generate a url properly with more than one parent with PUT", ->
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.PUT, options, context)
			expect( ret ).toBe("/c/3/b/2/")
		#END it

		it "Should generate a url properly with more than one parent with DELETE", ->
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.DELETE, options, context)
			expect( ret ).toBe("/c/3/b/2/")
		#END it


		it "Should generate a url properly using the parent from within options with GET", ->
			options.parent = new Falcon.Model({id: 4, endpoint: "d"})
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("/d/4/")
		#END it

		it "Should generate a url properly using the parent from within options with POST", ->
			options.parent = new Falcon.Model({id: 4, endpoint: "d"})
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.POST, options, context)
			expect( ret ).toBe("/d/4/")
		#END it

		it "Should generate a url properly using the parent from within options with PUT", ->
			options.parent = new Falcon.Model({id: 4, endpoint: "d"})
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.PUT, options, context)
			expect( ret ).toBe("/d/4/")
		#END it

		it "Should generate a url properly using the parent from within options with DELETE", ->
			options.parent = new Falcon.Model({id: 4, endpoint: "d"})
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.DELETE, options, context)
			expect( ret ).toBe("/d/4/")
		#END it


		it "Should include the base api url with regular parent", ->
			Falcon.baseApiUrl = "http://www.falconjs.com"
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("http://www.falconjs.com/c/3/b/2/")
		#END it

		it "Should include the base api url with regular parent and a trailing slash", ->
			Falcon.baseApiUrl = "http://www.falconjs.com/"
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("http://www.falconjs.com/c/3/b/2/")
		#END it


		it "Should include the base api url with an options parent", ->
			Falcon.baseApiUrl = "http://www.falconjs.com"
			options.parent = new Falcon.Model({id: 4, endpoint: "d"})
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("http://www.falconjs.com/d/4/")
		#END it

		it "Should include the base api url with an options parent and a trailing slash", ->
			Falcon.baseApiUrl = "http://www.falconjs.com/"
			options.parent = new Falcon.Model({id: 4, endpoint: "d"})
			parent_model = new Falcon.Model({id: 3, endpoint: "c"})
			data_object.parent = new Falcon.Model({id: 2, endpoint: "b"}, parent_model)
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("http://www.falconjs.com/d/4/")
		#END it


		it "Should include the base api url without a parent", ->
			Falcon.baseApiUrl = "http://www.falconjs.com"
			data_object.parent = null
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("http://www.falconjs.com/")
		#END it

		it "Should include the base api url without a parent and a trailing slash", ->
			Falcon.baseApiUrl = "http://www.falconjs.com/"
			data_object.parent = null
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("http://www.falconjs.com/")
		#END it


		it "Should include the base api url with an empty base url", ->
			Falcon.baseApiUrl = ""
			data_object.parent = null
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("/")
		#END it

		it "Should include the base api url with the root basse url", ->
			Falcon.baseApiUrl = "/"
			data_object.parent = null
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("/")
		#END it

		it "Should include the base api url with the root base url and a trailing slash", ->
			Falcon.baseApiUrl = "//"
			data_object.parent = null
			ret = adapter.makeBaseUrl( data_object, Falcon.GET, options, context)
			expect( ret ).toBe("/")
		#END it
	#END describe

	describe "makeUrlComponents", ->
		adapter = null
		base_api_url = null
		data_object = null
		options = null
		context = null

		beforeEach ->
			base_api_url = Falcon.baseApiUrl
			Falcon.baseApiUrl = "http://www.falconjs.com/"

			adapter = new Falcon.DataAdapter
			spyOn( adapter, "resolveRequestType" ).and.callThrough()
			spyOn( adapter, "makeBaseUrl" ).and.callThrough()

			data_object = new Falcon.Model({id: 1, endpoint: "a"})
			options = {}
			context = data_object
		#END beforeEach

		afterEach ->
			Falcon.baseApiUrl = base_api_url
		#END afterEach

		it "Should return the url components properly with GET", ->
			ret = adapter.makeUrlComponents( data_object, Falcon.GET, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.GET, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.GET, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "a"
				'id': "1"
				'extension': ""
			})
		#END it

		it "Should return the url components properly with POST", ->
			ret = adapter.makeUrlComponents( data_object, Falcon.POST, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.POST, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.POST, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "a"
				'id': "1"
				'extension': ""
			})
		#END it

		it "Should return the url components properly with PUT", ->
			ret = adapter.makeUrlComponents( data_object, Falcon.PUT, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.PUT, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.PUT, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "a"
				'id': "1"
				'extension': ""
			})
		#END it

		it "Should return the url components properly with DELETE", ->
			ret = adapter.makeUrlComponents( data_object, Falcon.DELETE, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "a"
				'id': "1"
				'extension': ""
			})
		#END it

		it "Should get the correct endpoint wiht a url method definition on the data object", ->
			data_object.endpoint = -> "b"

			ret = adapter.makeUrlComponents( data_object, Falcon.DELETE, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "b"
				'id': "1"
				'extension': ""
			})
		#END it

		it "Should remove slashes from the endpoint", ->
			data_object.endpoint = "/c//"

			ret = adapter.makeUrlComponents( data_object, Falcon.DELETE, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "c"
				'id': "1"
				'extension': ""
			})
		#END it

		it "Should be able to handle extensions properly", ->
			data_object.endpoint = "d.json"

			ret = adapter.makeUrlComponents( data_object, Falcon.DELETE, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "d"
				'id': "1"
				'extension': ".json"
			})
		#END it

		it "Should be able to handle extensions properly only after the last slash", ->
			data_object.endpoint = "d.json/hello"

			ret = adapter.makeUrlComponents( data_object, Falcon.DELETE, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "d.json/hello"
				'id': "1"
				'extension': ""
			})
		#END it

		it "Should handle collections properly", ->
			ModelE = Falcon.Model.extend({endpoint: 'e'})
			CollectionE = Falcon.Collection.extend({model: ModelE})
			data_object = new CollectionE

			ret = adapter.makeUrlComponents( data_object, Falcon.DELETE, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "e"
				'id': null
				'extension': ""
			})
		#END it

		it "Should handle collections with extensions properly", ->
			ModelE = Falcon.Model.extend({endpoint: 'e.json'})
			CollectionE = Falcon.Collection.extend({model: ModelE})
			data_object = new CollectionE

			ret = adapter.makeUrlComponents( data_object, Falcon.DELETE, options, context )

			expect( adapter.resolveRequestType.calls.count() ).toBe( 1 )
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( adapter.makeBaseUrl.calls.count() ).toBe( 1 )
			expect( adapter.makeBaseUrl ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( ret ).toEqual({
				'base_url': "http://www.falconjs.com/"
				'endpoint': "e"
				'id': null
				'extension': ".json"
			})
		#END it
	#END describe

	describe "makeUrl", ->
		adapter = null
		base_api_url = null
		data_object = null
		parent_object = null
		options = null
		context = null

		beforeEach ->
			base_api_url = Falcon.baseApiUrl
			Falcon.baseApiUrl = "http://www.falconjs.com/"

			parent_object = new Falcon.Model({id: 2, endpoint: "b"})
			data_object = new Falcon.Model({id: 1, endpoint: "a.json"}, parent_object)
			options = {}
			context = data_object

			adapter = new Falcon.DataAdapter
			spyOn( adapter, "makeUrlComponents" ).and.callThrough()
		#END beforeEach

		afterEach ->
			Falcon.baseApiUrl = base_api_url
		#END afterEach

		it "Should return the correct url on GET", ->
			ret = adapter.makeUrl( data_object, Falcon.GET, options, context )

			expect( adapter.makeUrlComponents.calls.count() ).toBe( 1 )
			expect( adapter.makeUrlComponents ).toHaveBeenCalledWith( data_object, Falcon.GET, options, context )

			expect( ret ).toBe( "http://www.falconjs.com/b/2/a/1.json" )
		#END it

		it "Should return the correct url on POST", ->
			ret = adapter.makeUrl( data_object, Falcon.POST, options, context )

			expect( adapter.makeUrlComponents.calls.count() ).toBe( 1 )
			expect( adapter.makeUrlComponents ).toHaveBeenCalledWith( data_object, Falcon.POST, options, context )

			expect( ret ).toBe( "http://www.falconjs.com/b/2/a.json" )
		#END it

		it "Should return the correct url on PUT", ->
			ret = adapter.makeUrl( data_object, Falcon.PUT, options, context )

			expect( adapter.makeUrlComponents.calls.count() ).toBe( 1 )
			expect( adapter.makeUrlComponents ).toHaveBeenCalledWith( data_object, Falcon.PUT, options, context )

			expect( ret ).toBe( "http://www.falconjs.com/b/2/a/1.json" )
		#END it

		it "Should return the correct url on DELETE", ->
			ret = adapter.makeUrl( data_object, Falcon.DELETE, options, context )

			expect( adapter.makeUrlComponents.calls.count() ).toBe( 1 )
			expect( adapter.makeUrlComponents ).toHaveBeenCalledWith( data_object, Falcon.DELETE, options, context )

			expect( ret ).toBe( "http://www.falconjs.com/b/2/a/1.json" )
		#END it

		it "Should return the correct url on GET with a collection", ->
			ModelE = Falcon.Model.extend({endpoint: 'e.json'})
			CollectionE = Falcon.Collection.extend({model: ModelE})
			data_object = new CollectionE

			ret = adapter.makeUrl( data_object, Falcon.GET, options, context )

			expect( adapter.makeUrlComponents.calls.count() ).toBe( 1 )
			expect( adapter.makeUrlComponents ).toHaveBeenCalledWith( data_object, Falcon.GET, options, context )

			expect( ret ).toBe( "http://www.falconjs.com/e.json" )
		#END it
	#END describe

	describe "serializeData", ->
		adapter = new Falcon.DataAdapter
		parent = new Falcon.Model
		data_object = new Falcon.Model({id: 1}, parent)
		context = {id: 3}
		options = {
			data: {id: 4}
		}
		attributes = ["id","hello"]
		serialized_data = {'hello': 'world'}

		beforeEach ->
			spyOn( data_object, 'serialize' ).and.returnValue(serialized_data)
		#END beforeEach

		it "Should use the data attribute of options if one is present", ->
			expect( adapter.serializeData( data_object, Falcon.GET, options, context ) ).toBe( options.data )
			expect( adapter.serializeData( data_object, Falcon.POST, options, context ) ).toBe( options.data )
			expect( adapter.serializeData( data_object, Falcon.PUT, options, context ) ).toBe( options.data )
			expect( adapter.serializeData( data_object, Falcon.DELETE, options, context ) ).toBe( options.data )

			expect( data_object.serialize ).not.toHaveBeenCalled()
		#END it

		it "Should call the serialize method on the data object if the request type is POST", ->
			ret = adapter.serializeData( data_object, Falcon.POST, {attributes}, context )
			
			expect( data_object.serialize.calls.count() ).toBe( 1 )
			expect( data_object.serialize ).toHaveBeenCalledWith( attributes )
			
			expect( ret ).toBe( serialized_data )
		#END it

		it "Should call the serialize method on the data object if the request type is PUT", ->
			ret = adapter.serializeData( data_object, Falcon.PUT, {attributes}, context )
			
			expect( data_object.serialize.calls.count() ).toBe( 1 )
			expect( data_object.serialize ).toHaveBeenCalledWith( attributes )
			
			expect( ret ).toBe( serialized_data )
		#END it

		it "Should not call serialzie on GET or DELETE", ->
			ret = adapter.serializeData( data_object, Falcon.GET, {attributes}, context )
			ret = adapter.serializeData( data_object, Falcon.DELETE, {attributes}, context )
			
			expect( data_object.serialize ).not.toHaveBeenCalled()
			
			expect( ret ).not.toBeDefined()
		#END it
	#END describe

	describe "parseRawResponseData", ->
		adapter = new Falcon.DataAdapter
		parent = new Falcon.Model
		data_object = new Falcon.Model({id: 1}, parent)
		type = Falcon.GET
		context = {id: 3}
		options = {}
		response_args = {id: 5}

		it "Should simply return the response arguments for the base adapter class", ->
			expect( adapter.parseRawResponseData(data_object, type, options, context, response_args) ).toBe( response_args )
		#END it
	#END describe

	describe "successResponseHandler", ->
		adapter = new Falcon.DataAdapter
		parent = new Falcon.Model
		data_object = new Falcon.Model({id: 1}, parent)
		context = new Falcon.Model({id: 2}, parent)
		type = Falcon.GET

		success = sinon.spy()
		error = sinon.spy()
		complete = sinon.spy()
		fill_options = {'method': 'merge'}
		options = {success, error, complete, fill_options}

		parsed_data = {id: 5}
		raw_response_data = {model: parsed_data}
		response_args = {data: JSON.stringify(raw_response_data)}

		beforeEach ->
			spyOn( adapter, 'parseRawResponseData' ).and.returnValue(raw_response_data)

			spyOn( data_object, 'parse' ).and.returnValue(parsed_data)
			spyOn( data_object, 'fill' )
			spyOn( data_object, 'trigger' )

			success.reset()
			error.reset()
			complete.reset()
		#END beforeEach

		it "Should call the correct methods on GET", ->
			type = Falcon.GET
			adapter.successResponseHandler( data_object, type, options, context, response_args )

			expect( adapter.parseRawResponseData.calls.count() ).toBe( 1 )
			expect( adapter.parseRawResponseData ).toHaveBeenCalledWith( data_object, type, options, context, response_args )

			expect( data_object.parse.calls.count() ).toBe( 1 )
			expect( data_object.parse ).toHaveBeenCalledWith( raw_response_data, options )

			expect( data_object.fill.calls.count() ).toBe( 1 )
			expect( data_object.fill ).toHaveBeenCalledWith( parsed_data, options.fill_options )

			expect( data_object.trigger.calls.count() ).toBe( 1 )
			expect( data_object.trigger ).toHaveBeenCalledWith("fetch", parsed_data)

			expect( success.callCount ).toBe( 1 )
			expect( success ).toHaveBeenCalledWith( data_object, raw_response_data, options, response_args )
			expect( success ).toHaveBeenCalledOn( context )

			expect( error ).not.toHaveBeenCalled()
			expect( complete ).not.toHaveBeenCalled()
		#END it

		it "Should call the correct methods on POST", ->
			type = Falcon.POST
			adapter.successResponseHandler( data_object, type, options, context, response_args )

			expect( adapter.parseRawResponseData.calls.count() ).toBe( 1 )
			expect( adapter.parseRawResponseData ).toHaveBeenCalledWith( data_object, type, options, context, response_args )

			expect( data_object.parse.calls.count() ).toBe( 1 )
			expect( data_object.parse ).toHaveBeenCalledWith( raw_response_data, options )

			expect( data_object.fill.calls.count() ).toBe( 1 )
			expect( data_object.fill ).toHaveBeenCalledWith( parsed_data, options.fill_options )

			expect( data_object.trigger.calls.count() ).toBe( 1 )
			expect( data_object.trigger ).toHaveBeenCalledWith("create", parsed_data)

			expect( success.callCount ).toBe( 1 )
			expect( success ).toHaveBeenCalledWith( data_object, raw_response_data, options, response_args )
			expect( success ).toHaveBeenCalledOn( context )

			expect( error ).not.toHaveBeenCalled()
			expect( complete ).not.toHaveBeenCalled()
		#END it

		it "Should call the correct methods on PUT", ->
			type = Falcon.PUT
			adapter.successResponseHandler( data_object, type, options, context, response_args )

			expect( adapter.parseRawResponseData.calls.count() ).toBe( 1 )
			expect( adapter.parseRawResponseData ).toHaveBeenCalledWith( data_object, type, options, context, response_args )

			expect( data_object.parse.calls.count() ).toBe( 1 )
			expect( data_object.parse ).toHaveBeenCalledWith( raw_response_data, options )

			expect( data_object.fill.calls.count() ).toBe( 1 )
			expect( data_object.fill ).toHaveBeenCalledWith( parsed_data, options.fill_options )

			expect( data_object.trigger.calls.count() ).toBe( 1 )
			expect( data_object.trigger ).toHaveBeenCalledWith("save", parsed_data)

			expect( success.callCount ).toBe( 1 )
			expect( success ).toHaveBeenCalledWith( data_object, raw_response_data, options, response_args )
			expect( success ).toHaveBeenCalledOn( context )

			expect( error ).not.toHaveBeenCalled()
			expect( complete ).not.toHaveBeenCalled()
		#END it

		it "Should call the correct methods on DELETE", ->
			type = Falcon.DELETE
			adapter.successResponseHandler( data_object, type, options, context, response_args )

			expect( adapter.parseRawResponseData.calls.count() ).toBe( 1 )
			expect( adapter.parseRawResponseData ).toHaveBeenCalledWith( data_object, type, options, context, response_args )

			expect( data_object.parse.calls.count() ).toBe( 1 )
			expect( data_object.parse ).toHaveBeenCalledWith( raw_response_data, options )

			expect( data_object.fill.calls.count() ).toBe( 1 )
			expect( data_object.fill ).toHaveBeenCalledWith( parsed_data, options.fill_options )

			expect( data_object.trigger.calls.count() ).toBe( 1 )
			expect( data_object.trigger ).toHaveBeenCalledWith("destroy", parsed_data)

			expect( success.callCount ).toBe( 1 )
			expect( success ).toHaveBeenCalledWith( data_object, raw_response_data, options, response_args )
			expect( success ).toHaveBeenCalledOn( context )

			expect( error ).not.toHaveBeenCalled()
			expect( complete ).not.toHaveBeenCalled()
		#END it
	#END describe

	describe "errorResponseHandler", ->
		adapter = new Falcon.DataAdapter
		parent = new Falcon.Model
		data_object = new Falcon.Model({id: 1}, parent)
		context = new Falcon.Model({id: 2}, parent)
		type = Falcon.GET

		success = sinon.spy()
		error = sinon.spy()
		complete = sinon.spy()
		options = {success, error, complete}

		parsed_data = {id: 5}
		raw_response_data = {model: parsed_data}
		response_args = {data: JSON.stringify(raw_response_data)}

		beforeEach ->
			spyOn( adapter, 'parseRawResponseData' ).and.returnValue(raw_response_data)

			success.reset()
			error.reset()
			complete.reset()
		#END beforeEach

		it "Should call the error method correctly", ->
			adapter.errorResponseHandler( data_object, type, options, context, response_args )

			expect( adapter.parseRawResponseData.calls.count() ).toBe( 1 )
			expect( adapter.parseRawResponseData ).toHaveBeenCalledWith( data_object, type, options, context, response_args )

			expect( error.callCount ).toBe( 1 )
			expect( error ).toHaveBeenCalledWith( data_object, raw_response_data, options, response_args )
			expect( error ).toHaveBeenCalledOn( context )

			expect( success ).not.toHaveBeenCalled()
			expect( complete ).not.toHaveBeenCalled()
		#END it
	#END describe

	describe "completeResponseHandler", ->
		adapter = new Falcon.DataAdapter
		parent = new Falcon.Model
		data_object = new Falcon.Model({id: 1}, parent)
		context = new Falcon.Model({id: 2}, parent)
		type = Falcon.GET

		success = sinon.spy()
		error = sinon.spy()
		complete = sinon.spy()
		options = {success, error, complete}

		parsed_data = {id: 5}
		raw_response_data = {model: parsed_data}
		response_args = {data: JSON.stringify(raw_response_data)}

		beforeEach ->
			spyOn( adapter, 'parseRawResponseData' ).and.returnValue(raw_response_data)

			success.reset()
			error.reset()
			complete.reset()
		#END beforeEach

		it "Should call the complete method correctly", ->
			adapter.completeResponseHandler( data_object, type, options, context, response_args )

			expect( adapter.parseRawResponseData.calls.count() ).toBe( 1 )
			expect( adapter.parseRawResponseData ).toHaveBeenCalledWith( data_object, type, options, context, response_args )
			
			expect( complete.callCount ).toBe( 1 )
			expect( complete ).toHaveBeenCalledWith( data_object, raw_response_data, options, response_args )
			expect( complete ).toHaveBeenCalledOn( context )

			expect( success ).not.toHaveBeenCalled()
			expect( error ).not.toHaveBeenCalled()
		#END it
	#END describe

	describe "sync", ->
		adapter = new Falcon.DataAdapter
		parent = new Falcon.Model
		data_object = new Falcon.Model({id: 1}, parent)
		context = new Falcon.Model({id: 2}, parent)
		type = Falcon.GET
		options = {}

		beforeEach ->
			sinonSpyOn( adapter, 'resolveRequestType' )
			sinonSpyOn( adapter, 'standardizeOptions' )
			sinonSpyOn( adapter, 'resolveContext' )
			sinonSpyOn( data_object, 'validate' )
		#END beforeEach

		it "Should throw if a data object isn't passed in", ->
			expect( -> adapter.sync() ).toThrow()
			expect( -> adapter.sync(123) ).toThrow()
			expect( -> adapter.sync(new Falcon.View) ).toThrow()

			expect( adapter.resolveRequestType ).not.toHaveBeenCalled()
			expect( adapter.standardizeOptions ).not.toHaveBeenCalled()
			expect( adapter.resolveContext ).not.toHaveBeenCalled()
			expect( data_object.validate ).not.toHaveBeenCalled()
		#END it

		it "Should return properly on GET", ->
			type = Falcon.GET
			ret = adapter.sync( data_object, type, options, context )

			expect( adapter.resolveRequestType ).toHaveBeenCalledOnce()
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, type, options, context )

			expect( adapter.standardizeOptions ).toHaveBeenCalledOnce()
			expect( adapter.standardizeOptions ).toHaveBeenCalledWith( data_object, type, options, context )
			expect( adapter.standardizeOptions ).toHaveBeenCalledAfter( adapter.resolveRequestType )

			expect( adapter.resolveContext ).toHaveBeenCalledOnce()
			expect( adapter.resolveContext ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
			expect( adapter.resolveContext ).toHaveBeenCalledAfter( adapter.standardizeOptions )

			expect( data_object.validate ).not.toHaveBeenCalled()

			expect( ret ).toEqual
				data_object: data_object
				type: Falcon.GET
				options: jasmine.any(Object)
				context: context
				is_valid: true
			#END toEqual
		#END it

		it "Should return properly on POST", ->
			type = Falcon.POST
			ret = adapter.sync( data_object, type, options, context )

			expect( adapter.resolveRequestType ).toHaveBeenCalledOnce()
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, type, options, context )

			expect( adapter.standardizeOptions ).toHaveBeenCalledOnce()
			expect( adapter.standardizeOptions ).toHaveBeenCalledWith( data_object, type, options, context )
			expect( adapter.standardizeOptions ).toHaveBeenCalledAfter( adapter.resolveRequestType )

			expect( adapter.resolveContext ).toHaveBeenCalledOnce()
			expect( adapter.resolveContext ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
			expect( adapter.resolveContext ).toHaveBeenCalledAfter( adapter.standardizeOptions )

			expect( data_object.validate ).toHaveBeenCalledOnce()
			expect( data_object.validate ).toHaveBeenCalledWith( jasmine.any(Object) )
			expect( data_object.validate ).toHaveBeenCalledAfter( adapter.resolveContext )

			expect( ret ).toEqual
				data_object: data_object
				type: Falcon.POST
				options: jasmine.any(Object)
				context: context
				is_valid: true
			#END toEqual
		#END it

		it "Should return properly on PUT", ->
			type = Falcon.PUT
			ret = adapter.sync( data_object, type, options, context )

			expect( adapter.resolveRequestType ).toHaveBeenCalledOnce()
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, type, options, context )

			expect( adapter.standardizeOptions ).toHaveBeenCalledOnce()
			expect( adapter.standardizeOptions ).toHaveBeenCalledWith( data_object, type, options, context )
			expect( adapter.standardizeOptions ).toHaveBeenCalledAfter( adapter.resolveRequestType )

			expect( adapter.resolveContext ).toHaveBeenCalledOnce()
			expect( adapter.resolveContext ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
			expect( adapter.resolveContext ).toHaveBeenCalledAfter( adapter.standardizeOptions )

			expect( data_object.validate ).toHaveBeenCalledOnce()
			expect( data_object.validate ).toHaveBeenCalledWith( jasmine.any(Object) )
			expect( data_object.validate ).toHaveBeenCalledAfter( adapter.resolveContext )

			expect( ret ).toEqual
				data_object: data_object
				type: Falcon.PUT
				options: jasmine.any(Object)
				context: context
				is_valid: true
			#END toEqual
		#END it

		it "Should return properly on DELETE", ->
			type = Falcon.DELETE
			ret = adapter.sync( data_object, type, options, context )

			expect( adapter.resolveRequestType ).toHaveBeenCalledOnce()
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, type, options, context )

			expect( adapter.standardizeOptions ).toHaveBeenCalledOnce()
			expect( adapter.standardizeOptions ).toHaveBeenCalledWith( data_object, type, options, context )
			expect( adapter.standardizeOptions ).toHaveBeenCalledAfter( adapter.resolveRequestType )

			expect( adapter.resolveContext ).toHaveBeenCalledOnce()
			expect( adapter.resolveContext ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
			expect( adapter.resolveContext ).toHaveBeenCalledAfter( adapter.standardizeOptions )

			expect( data_object.validate ).not.toHaveBeenCalled()

			expect( ret ).toEqual
				data_object: data_object
				type: Falcon.DELETE
				options: jasmine.any(Object)
				context: context
				is_valid: true
			#END toEqual
		#END it

		it "Should return properly with a failed POST validation", ->
			type = Falcon.POST
			data_object.validate = sinon.spy( -> return false )
			ret = adapter.sync( data_object, type, options, context )

			expect( adapter.resolveRequestType ).toHaveBeenCalledOnce()
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, type, options, context )

			expect( adapter.standardizeOptions ).toHaveBeenCalledOnce()
			expect( adapter.standardizeOptions ).toHaveBeenCalledWith( data_object, type, options, context )
			expect( adapter.standardizeOptions ).toHaveBeenCalledAfter( adapter.resolveRequestType )

			expect( adapter.resolveContext ).toHaveBeenCalledOnce()
			expect( adapter.resolveContext ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
			expect( adapter.resolveContext ).toHaveBeenCalledAfter( adapter.standardizeOptions )

			expect( data_object.validate ).toHaveBeenCalledOnce()
			expect( data_object.validate ).toHaveBeenCalledWith( jasmine.any(Object) )
			expect( data_object.validate ).toHaveBeenCalledAfter( adapter.resolveContext )

			expect( ret ).toEqual
				data_object: data_object
				type: Falcon.POST
				options: jasmine.any(Object)
				context: context
				is_valid: false
			#END toEqual
		#END it

		it "Should return properly with a failed PUT validation", ->
			type = Falcon.PUT
			data_object.validate = sinon.spy( -> return false )
			ret = adapter.sync( data_object, type, options, context )

			expect( adapter.resolveRequestType ).toHaveBeenCalledOnce()
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, type, options, context )

			expect( adapter.standardizeOptions ).toHaveBeenCalledOnce()
			expect( adapter.standardizeOptions ).toHaveBeenCalledWith( data_object, type, options, context )
			expect( adapter.standardizeOptions ).toHaveBeenCalledAfter( adapter.resolveRequestType )

			expect( adapter.resolveContext ).toHaveBeenCalledOnce()
			expect( adapter.resolveContext ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
			expect( adapter.resolveContext ).toHaveBeenCalledAfter( adapter.standardizeOptions )

			expect( data_object.validate ).toHaveBeenCalledOnce()
			expect( data_object.validate ).toHaveBeenCalledWith( jasmine.any(Object) )
			expect( data_object.validate ).toHaveBeenCalledAfter( adapter.resolveContext )

			expect( ret ).toEqual
				data_object: data_object
				type: Falcon.PUT
				options: jasmine.any(Object)
				context: context
				is_valid: false
			#END toEqual
		#END it

		it "Should not call validate on a collection", ->
			type = Falcon.POST
			data_object = new Falcon.Collection
			data_object.validate = sinon.spy( -> return false )
			ret = adapter.sync( data_object, type, options, context )

			expect( adapter.resolveRequestType ).toHaveBeenCalledOnce()
			expect( adapter.resolveRequestType ).toHaveBeenCalledWith( data_object, type, options, context )

			expect( adapter.standardizeOptions ).toHaveBeenCalledOnce()
			expect( adapter.standardizeOptions ).toHaveBeenCalledWith( data_object, type, options, context )
			expect( adapter.standardizeOptions ).toHaveBeenCalledAfter( adapter.resolveRequestType )

			expect( adapter.resolveContext ).toHaveBeenCalledOnce()
			expect( adapter.resolveContext ).toHaveBeenCalledWith( data_object, type, jasmine.any(Object), context )
			expect( adapter.resolveContext ).toHaveBeenCalledAfter( adapter.standardizeOptions )

			expect( data_object.validate ).not.toHaveBeenCalled()

			expect( ret ).toEqual
				data_object: data_object
				type: Falcon.POST
				options: jasmine.any(Object)
				context: context
				is_valid: true
			#END toEqual
		#END it
	#END describe
#END describe