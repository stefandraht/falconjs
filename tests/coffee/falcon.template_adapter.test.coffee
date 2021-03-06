describe "Falcon.TemplateAdapter", ->
	describe "constructor", ->
		beforeEach ->
			spyOn(Falcon.Object::, 'constructor').and.callThrough()
			spyOn(document, 'createElement')
		#END beforeEach

		it "Should call the correct methods", ->
			adapter = new Falcon.TemplateAdapter("A", "b", 3)

			expect( Falcon.Object::constructor.calls.count() ).toBe( 1 )
			expect( Falcon.Object::constructor ).toHaveBeenCalledWith("A", "b", 3)

			expect( document.createElement.calls.count() ).toBe( 1 )
			expect( document.createElement ).toHaveBeenCalledWith("template")

			expect( adapter ).toEqual(jasmine.any(Falcon.Object))
		#END it
	#END describe

	describe "cacheTemplate", ->
		adapter = new Falcon.TemplateAdapter

		it "Should throw if a string identifier isn't given", ->
			expect( -> adapter.cacheTemplate() ).toThrow()
			expect( -> adapter.cacheTemplate(new Falcon.Model) ).toThrow()
		#END it

		it "Should throw if a string template isn't given", ->
			expect( -> adapter.cacheTemplate("#hello_world") ).toThrow()
			expect( -> adapter.cacheTemplate("#hello_world", new Falcon.Model) ).toThrow()
		#END it

		it "Should cache properly", ->
			expect( adapter.getCachedTemplate("#hello_world") ).toBeNull()

			ret = adapter.cacheTemplate("#hello_world", "Hello World")
			expect( ret ).toBe( adapter )

			expect( adapter.getCachedTemplate("#hello_world") ).toBe("Hello World")
		#END it
	#END describe

	describe "getCachedTemplate", ->
		adapter = new Falcon.TemplateAdapter

		it "Should through if a string isn't given", ->
			expect( -> adapter.getCachedTemplate() ).toThrow()
			expect( -> adapter.getCachedTemplate(new Falcon.Model) ).toThrow()
		#END it

		it "Should return null if a template isn't cached", ->
			expect( adapter.getCachedTemplate("#hello_world") ).toBeNull()
		#END it

		it "Should return the template if one exists", ->
			adapter.cacheTemplate("#hello_world", "Hello World")
			expect( adapter.getCachedTemplate("#hello_world") ).toBe("Hello World")
		#END it
	#END describe

	describe "resetCache", ->
		adapter = new Falcon.TemplateAdapter
		it "Should reset the template cache properly", ->
			ret = adapter.getCachedTemplate("#hello_world")
			expect( ret ).toBe( null )

			adapter.cacheTemplate("#hello_world", "Hello World")
			ret = adapter.getCachedTemplate("#hello_world")
			expect( ret ).toBe( "Hello World" )

			ret = adapter.resetCache()
			expect( ret ).toBe( adapter )

			ret = adapter.getCachedTemplate("#hello_world")
			expect( ret ).toBe( null )
		#END it
	#END describe

	describe "cacheAllTemplates", ->
		template = document.createElement("template")
		template.setAttribute("id", "test_template_1")
		template.innerHTML = "Hello World 1"

		template2 = document.createElement("template")
		template2.setAttribute("id", "test_template_2")
		template2.innerHTML = "Hello World 2"

		beforeEach ->
			document.body.appendChild( template )
			document.body.appendChild( template2 )

			spyOn( Falcon.templateAdapter, 'cacheTemplate' )
		#END beforeEach

		it "Should have removed and cached the templates", ->
			templates = document.getElementsByTagName("template")
			expect( templates.length ).toBe( 2 )
			
			ret = Falcon.templateAdapter.cacheAllTemplates()
			
			templates = document.getElementsByTagName("template")
			expect( templates.length ).toBe( 0 )

			expect( Falcon.templateAdapter.cacheTemplate.calls.count() ).toBe( 2 )
			expect( Falcon.templateAdapter.cacheTemplate.calls.argsFor(0) ).toEqual [
				'#test_template_1'
				'Hello World 1'
			]

			expect( Falcon.templateAdapter.cacheTemplate.calls.argsFor(1) ).toEqual [
				'#test_template_2'
				'Hello World 2'
			]

			expect( ret ).toBe( Falcon.templateAdapter )
		#END it

		it "Should work properly if no templates exist", ->
			document.body.removeChild( template )
			document.body.removeChild( template2 )
			
			templates = document.getElementsByTagName("template")
			expect( templates.length ).toBe( 0 )
			
			ret = Falcon.templateAdapter.cacheAllTemplates()
			
			templates = document.getElementsByTagName("template")
			expect( templates.length ).toBe( 0 )

			expect( ret ).toBe( Falcon.templateAdapter )
		#END it
	#END describe

	describe "resolveTemplate", ->
		adapter = null
		endpoint = "#hello_world"
		template = "Hello World"
		callback = null
		element = null
		view = null

		beforeEach ->
			adapter ?= new Falcon.TemplateAdapter
			view = MockHelper.makeView(endpoint)
			callback = jasmine.createSpy()
			spyOn(adapter, 'loadTemplate')
			spyOn(adapter, 'getCachedTemplate').and.callThrough()
			spyOn(view, 'makeUrl').and.callThrough()

			adapter.resetCache()
			view.template = null
		#END beforeEach

		it "Should throw if an invalid view is given", ->
			expect( -> adapter.resolveTemplate() ).toThrow()
			expect( -> adapter.resolveTemplate( new Falcon.Collection ) ).toThrow()
		#END it

		it "Should throw if an invalid callback is given", ->
			expect( -> adapter.resolveTemplate( new Falcon.View ) ).toThrow()
			expect( -> adapter.resolveTemplate( new Falcon.View, 123) ).toThrow()
		#END it

		it "Should call the loadTemplate method if the url is valid and the template hasn't been cached", ->

			ret = adapter.resolveTemplate(view, callback)

			expect( view.makeUrl.calls.count() ).toBe( 1 )

			expect( adapter.getCachedTemplate.calls.count() ).toBe( 1 )
			expect( adapter.getCachedTemplate ).toHaveBeenCalledWith( jasmine.any(String) )

			expect( adapter.loadTemplate.calls.count() ).toBe( 1 )
			expect( adapter.loadTemplate ).toHaveBeenCalledWith( jasmine.any(String), callback )

			expect( callback ).not.toHaveBeenCalled()

			expect( ret ).toBe( adapter )
		#END it

		it "Should return the cached value if one exists", ->
			adapter.cacheTemplate(endpoint, template)
			ret = adapter.resolveTemplate(view, callback)

			expect( view.makeUrl.calls.count() ).toBe( 1 )

			expect( adapter.getCachedTemplate.calls.count() ).toBe( 1 )
			expect( adapter.getCachedTemplate ).toHaveBeenCalledWith( jasmine.any(String) )

			expect( adapter.loadTemplate ).not.toHaveBeenCalled()

			expect( callback.calls.count() ).toBe( 1 )
			expect( callback ).toHaveBeenCalledWith(template)

			expect( ret ).toBe( adapter )
		#END it

		it "Should return an empty string if the url is empty", ->
			view.makeUrl = jasmine.createSpy("makeUrl").and.returnValue("")
			ret = adapter.resolveTemplate(view, callback)

			expect( view.makeUrl.calls.count() ).toBe( 1 )

			expect( adapter.getCachedTemplate ).not.toHaveBeenCalled()
			expect( adapter.loadTemplate ).not.toHaveBeenCalled()

			expect( callback.calls.count() ).toBe( 1 )
			expect( callback ).toHaveBeenCalledWith("")

			expect( ret ).toBe( adapter )
		#END it

		it "Should us the pre-defined template if one exists", ->
			view.template = "Foo Bar"
			ret = adapter.resolveTemplate(view, callback)

			expect( view.makeUrl ).not.toHaveBeenCalled()
			expect( adapter.getCachedTemplate ).not.toHaveBeenCalled()
			expect( adapter.loadTemplate ).not.toHaveBeenCalled()

			expect( callback.calls.count() ).toBe( 1 )
			expect( callback ).toHaveBeenCalledWith("Foo Bar")

			expect( ret ).toBe( adapter )
		#END it
	#END describe

	describe "loadTemplate", ->
		adapter = new Falcon.TemplateAdapter
		hello_world = null

		beforeEach ->
			spyOn(Falcon, "ready")
			spyOn(adapter, 'cacheTemplate')

			hello_world = MockHelper.makeElement("template")
                                    .setId("hello_world")
                                    .html("Hello World")
                                    .addToDOM()
		#END beforeEach

		afterEach ->
			hello_world.removeFromDOM()
		#END afterEach

		it "Should exception if a url string isn't given", ->
			expect( -> adapter.loadTemplate(new Falcon.Model, (->)) ).toThrow()
		#END it

		it "Should exception if a function is't given", ->
			expect( -> adapter.loadTemplate("#hello_world", new Falcon.Model)  ).toThrow()
		#END it

		it "Should execute properly", ->
			callback_spy = jasmine.createSpy("Template Spy")
			ret = adapter.loadTemplate("#hello_world", callback_spy)

			expect( Falcon.ready.calls.count() ).toBe( 1 )
			expect( Falcon.ready ).toHaveBeenCalledWith( jasmine.any(Function) )

			expect( adapter.cacheTemplate ).not.toHaveBeenCalled()
			expect( callback_spy ).not.toHaveBeenCalled()

			# Second half of execution after falcon.ready has been executed
			ready_callback = Falcon.ready.calls.argsFor(0)[0]
			ready_callback()

			# Second Half Tests
			expect( Falcon.ready.calls.count() ).toBe( 1 )
			expect( Falcon.ready ).toHaveBeenCalledWith( jasmine.any(Function) )

			expect( adapter.cacheTemplate.calls.count() ).toBe( 1 )
			expect( adapter.cacheTemplate ).toHaveBeenCalledWith( "#hello_world", "Hello World" )

			expect( callback_spy.calls.count() ).toBe( 1 )
			expect( callback_spy ).toHaveBeenCalledWith( "Hello World" )

			expect( ret ).toBe( adapter )
		#END it

		it "Should execute proparly with a not-found element id is given", ->
			callback_spy = jasmine.createSpy("Template Spy")
			ret = adapter.loadTemplate("#foo_bar", callback_spy)

			expect( Falcon.ready.calls.count() ).toBe( 1 )
			expect( Falcon.ready ).toHaveBeenCalledWith( jasmine.any(Function) )

			expect( adapter.cacheTemplate ).not.toHaveBeenCalled()
			expect( callback_spy ).not.toHaveBeenCalled()

			# Second half of execution after falcon.ready has been executed
			ready_callback = Falcon.ready.calls.argsFor(0)[0]
			ready_callback()

			# Second Half Tests
			expect( Falcon.ready.calls.count() ).toBe( 1 )
			expect( Falcon.ready ).toHaveBeenCalledWith( jasmine.any(Function) )

			expect( adapter.cacheTemplate.calls.count() ).toBe( 1 )
			expect( adapter.cacheTemplate ).toHaveBeenCalledWith( "#foo_bar", "" )

			expect( callback_spy.calls.count() ).toBe( 1 )
			expect( callback_spy ).toHaveBeenCalledWith( "" )

			expect( ret ).toBe( adapter )
		#END it
	#END describe

	describe "makeUrl", ->

		class ViewD extends Falcon.View
			endpoint: -> '#view_d'
		#END class

		class ViewE extends Falcon.View
			endpoint: '/view_e'
		#END class

		class ViewF extends Falcon.View
			endpoint: -> '/view_f'
		#END class

		class ViewG extends Falcon.View
		#END class

		it "Should generate the correct relative url from string", ->
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("view_a") ) ).toEqual( "/view_a" )
		#END it

		it "Should generate the correct relative url from function", ->
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("view_b") ) ).toEqual( "/view_b" )
		#END it

		it "Should generate the correct element id from string", ->
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("#view_c") ) ).toEqual( "#view_c" )
		#END it

		it "Should generate the correct element id from function", ->
			expect( Falcon.templateAdapter.makeUrl( new ViewD ) ).toEqual( "#view_d" )
		#END it

		it "Should generate the correct relative url from string beginning with '/'", ->
			expect( Falcon.templateAdapter.makeUrl( new ViewE ) ).toEqual( "/view_e" )
		#END it

		it "Should generate the correct relative url from function beginning with '/'", ->
			expect( Falcon.templateAdapter.makeUrl( new ViewF ) ).toEqual( "/view_f" )
		#END it

			


		it "Should generate the correct relative url from string with baseTemplateUrl", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com"
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("view_a") ) ).toEqual( "http://www.falconjs.com/view_a" )
		#END it

		it "Should generate the correct relative url from function with baseTemplateUrl", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com"
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("view_b") ) ).toEqual( "http://www.falconjs.com/view_b" )
		#END it

		it "Should generate the correct element id from string with baseTemplateUrl", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com"
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("#view_c") ) ).toEqual( "#view_c" )
		#END it

		it "Should generate the correct element id from function with baseTemplateUrl", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com"
			expect( Falcon.templateAdapter.makeUrl( new ViewD ) ).toEqual( "#view_d" )
		#END it

		it "Should generate the correct relative url from string beginning with '/' with baseTemplateUrl", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com"
			expect( Falcon.templateAdapter.makeUrl( new ViewE ) ).toEqual( "http://www.falconjs.com/view_e" )
		#END it

		it "Should generate the correct relative url from function beginning with '/' with baseTemplateUrl", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com"
			expect( Falcon.templateAdapter.makeUrl( new ViewF ) ).toEqual( "http://www.falconjs.com/view_f" )
		#END it

			


		it "Should generate the correct relative url from string with baseTemplateUrl ending in '/'", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com/"
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("view_a") ) ).toEqual( "http://www.falconjs.com/view_a" )
		#END it

		it "Should generate the correct relative url from function with baseTemplateUrl ending in '/'", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com/"
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("view_b") ) ).toEqual( "http://www.falconjs.com/view_b" )
		#END it

		it "Should generate the correct element id from string with baseTemplateUrl ending in '/'", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com/"
			expect( Falcon.templateAdapter.makeUrl( MockHelper.makeView("#view_c") ) ).toEqual( "#view_c" )
		#END it

		it "Should generate the correct element id from function with baseTemplateUrl ending in '/'", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com/"
			expect( Falcon.templateAdapter.makeUrl( new ViewD ) ).toEqual( "#view_d" )
		#END it

		it "Should generate the correct relative url from string beginning with '/' with baseTemplateUrl ending in '/'", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com/"
			expect( Falcon.templateAdapter.makeUrl( new ViewE ) ).toEqual( "http://www.falconjs.com/view_e" )
		#END it

		it "Should generate the correct relative url from function beginning with '/' with baseTemplateUrl ending in '/'", ->
			Falcon.baseTemplateUrl = "http://www.falconjs.com/"
			expect( Falcon.templateAdapter.makeUrl( new ViewF ) ).toEqual( "http://www.falconjs.com/view_f" )
		#END it

		it "Should return an empty string if no url is defined", ->
			expect( Falcon.templateAdapter.makeUrl( new ViewG ) ).toEqual( "" )

			Falcon.baseTemplateUrl = "http://www.falconjs.com/"
			expect( Falcon.templateAdapter.makeUrl( new ViewG ) ).toEqual( "" )
		#END it
	#END describe
#END describe