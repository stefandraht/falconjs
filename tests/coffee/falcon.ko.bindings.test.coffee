describe "Bindings", ->
	describe "view", ->
		view_binding = Falcon.getBinding('view')

		beforeEach ->
			spyOn( ko.virtualElements, 'emptyNode' ).and.callThrough()

			spyOn( Falcon.View::, '_render' ).and.callThrough()
			spyOn( Falcon.View::, '_unrender' ).and.callThrough()

			# Just intercept some stuff so we can control state betetr
			spyOn( Falcon, 'ready' )
		#END beforeEach

		describe "Basic Exception Cases", ->
			it "Should initialize correctly, but empty the node if a view isn't given", ->
				test_view = {} # Invalid

				element = MockHelper.makeElement()
				                    .bindings("view: test_view")
				                    .html("Hello World")
				                    .andApply({
				                    	test_view: test_view
				                    })

				expect( ko.virtualElements.emptyNode.calls.count() ).toBe( 1 )
				expect( ko.virtualElements.emptyNode ).toHaveBeenCalledWith( element )

				expect( Falcon.View::_render ).not.toHaveBeenCalled()
				expect( Falcon.View::_unrender ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("")
			#END it

			it "Should initialize correctly, but empty the node if the view doesn't have a template", ->
				test_view = new Falcon.View()
				test_view.__falcon_view__loaded_template__(undefined)

				element = MockHelper.makeElement()
				                    .bindings("view: test_view")
				                    .html("Hello World")
				                    .andApply({
				                    	test_view: test_view
				                    })

				expect( ko.virtualElements.emptyNode.calls.count() ).toBe( 1 )
				expect( ko.virtualElements.emptyNode ).toHaveBeenCalledWith( element )

				expect( Falcon.View::_render ).not.toHaveBeenCalled()
				expect( Falcon.View::_unrender ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("")
			#END it
		#END describe

		describe "Observable Exception Cases", ->
			it "Should initialize correctly with observable, but empty the node if a view isn't given", ->
				test_view = {} # Invalid

				element = MockHelper.makeElement()
				                    .bindings("view: test_view")
				                    .html("Hello World")
				                    .andApply({
				                    	test_view: ko.observable(test_view)
				                    })

				expect( ko.virtualElements.emptyNode.calls.count() ).toBe( 1 )
				expect( ko.virtualElements.emptyNode ).toHaveBeenCalledWith( element )

				expect( Falcon.View::_render ).not.toHaveBeenCalled()
				expect( Falcon.View::_unrender ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("")
			#END it

			it "Should initialize correctly with observable, but empty the node if the view doesn't have a template", ->
				test_view = new Falcon.View()
				test_view.__falcon_view__loaded_template__(undefined)

				element = MockHelper.makeElement()
				                    .bindings("view: test_view")
				                    .html("Hello World")
				                    .andApply({
				                    	test_view: ko.observable(test_view)
				                    })

				expect( ko.virtualElements.emptyNode.calls.count() ).toBe( 1 )
				expect( ko.virtualElements.emptyNode ).toHaveBeenCalledWith( element )

				expect( Falcon.View::_render ).not.toHaveBeenCalled()
				expect( Falcon.View::_unrender ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("")
			#END it
		#END describe

		describe "Basic Usage", ->
			view = null
			element = null

			it "Setup", ->
				hello_world = MockHelper.makeElement("template")
				                        .setId("hello_world")
				                        .html("Hello World")
				                        .addToDOM()
			#END setup

			it "Should setup the view binding properly with a basic view", ->
				view = MockHelper.makeView("#hello_world", {template: "Hello World"})

				element = MockHelper.makeElement()
				                    .bindings("view: view")
				                    .addToDOM()
				                    .andApply({view})

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view._render.calls.count() ).toBe( 1 )
				expect( view.display.calls.count() ).toBe( 1 )

				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("Hello World")

				view.resetSpies()
			#END it

			it "Should unrender properly when removed from the DOM", ->
				element.removeFromDOM()

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()
				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()

				expect( view._unrender.calls.count() ).toBe( 1 )
				expect( view.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Basic Observable Usage", ->
			obs = ko.observable()
			element = null
			view_a = view_b = null

			it "Setup", ->
				hello_world = MockHelper.makeElement("template")
				                        .setId("hello_world")
				                        .html("Hello World")
				                        .addToDOM()

				foo_bar = MockHelper.makeElement("template")
				                    .setId("foo_bar")
				                    .html("Foo Bar")
				                    .addToDOM()
			#END setup

			it "Should apply blank observable properly", ->
				element = MockHelper.makeElement()
				                    .bindings("view: obs")
				                    .addToDOM()
				                    .andApply({obs})

				expect( ko.virtualElements.emptyNode.calls.count() ).toBe( 1 )
				expect( ko.virtualElements.emptyNode ).toHaveBeenCalledWith( element )

				expect( element.innerHTML ).toBe( "" )
			#END it

			it "Should update the template when a valid view with template is given", ->
				view_a = MockHelper.makeView("#hello_world", {template: "Hello World"})

				obs( view_a )

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render.calls.count() ).toBe( 1 )
				expect( view_a.display.calls.count() ).toBe( 1 )

				expect( view_a._unrender ).not.toHaveBeenCalled()
				expect( view_a.dispose ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("Hello World")

				view_a.resetSpies()
			#END it

			it "Should swap views properly", ->
				view_b = MockHelper.makeView("#foo_bar", {template: "Foo Bar"})

				obs( view_b )

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render ).not.toHaveBeenCalled()
				expect( view_a.display ).not.toHaveBeenCalled()

				expect( view_a._unrender.calls.count() ).toBe( 1 )
				expect( view_a.dispose.calls.count() ).toBe( 1 )

				expect( view_b._render.calls.count() ).toBe( 1 )
				expect( view_b.display.calls.count() ).toBe( 1 )

				expect( view_b._unrender ).not.toHaveBeenCalled()
				expect( view_b.dispose ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("Foo Bar")

				view_a.resetSpies()
				view_b.resetSpies()
			#END it

			it "Should unrender properly when removed from the DOM", ->
				element.removeFromDOM()

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render ).not.toHaveBeenCalled()
				expect( view_a.display ).not.toHaveBeenCalled()
				expect( view_a._unrender ).not.toHaveBeenCalled()
				expect( view_a.dispose ).not.toHaveBeenCalled()

				expect( view_b._render ).not.toHaveBeenCalled()
				expect( view_b.display ).not.toHaveBeenCalled()
				expect( view_b._unrender.calls.count() ).toBe( 1 )
				expect( view_b.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Basic Comment Binding Usage", ->
			comment = null
			view = null

			it "Should setup the view binding properly with basic view", ->
				view = MockHelper.makeView("hello_world", {template: "Hello World"})

				comment = MockHelper.makeCommentBinding("view: view")
									.addToDOM()
				                    .andApply({view})

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view._render.calls.count() ).toBe( 1 )
				expect( view.display.calls.count() ).toBe( 1 )

				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				expect( comment.getInnerHTML() ).toBe("Hello World")

				view.resetSpies()
			#END it

			it "Should unrender properly when removed from the DOM", ->
				comment.removeFromDOM()

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()
				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()

				expect( view._unrender.calls.count() ).toBe( 1 )
				expect( view.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Basic Observable Comment Binding Usage", ->
			obs = ko.observable()
			comment = null
			view_a = view_b = null

			it "Should apply blank observable properly", ->
				comment = MockHelper.makeCommentBinding("view: obs")
				                    .addToDOM()
				                    .andApply({obs})

				expect( ko.virtualElements.emptyNode.calls.count() ).toBe( 1 )
				expect( ko.virtualElements.emptyNode ).toHaveBeenCalledWith( comment.start_comment )

				expect( comment.getInnerHTML() ).toBe( "" )
			#END it

			it "Should update the template when a valid view with template is given", ->
				view_a = MockHelper.makeView("#hello_world", {template: "Hello World"})

				obs( view_a )

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render.calls.count() ).toBe( 1 )
				expect( view_a.display.calls.count() ).toBe( 1 )

				expect( view_a._unrender ).not.toHaveBeenCalled()
				expect( view_a.dispose ).not.toHaveBeenCalled()

				expect( comment.getInnerHTML() ).toBe("Hello World")

				view_a.resetSpies()
			#END it

			it "Should swap views properly", ->
				view_b = MockHelper.makeView("#foo_bar", {template: "Foo Bar"})

				obs( view_b )

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render ).not.toHaveBeenCalled()
				expect( view_a.display ).not.toHaveBeenCalled()

				expect( view_a._unrender.calls.count() ).toBe( 1 )
				expect( view_a.dispose.calls.count() ).toBe( 1 )

				expect( view_b._render.calls.count() ).toBe( 1 )
				expect( view_b.display.calls.count() ).toBe( 1 )

				expect( view_b._unrender ).not.toHaveBeenCalled()
				expect( view_b.dispose ).not.toHaveBeenCalled()

				expect( comment.getInnerHTML() ).toBe("Foo Bar")

				view_a.resetSpies()
				view_b.resetSpies()
			#END it

			it "Should unrender properly when removed from the DOM", ->
				comment.removeFromDOM()

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render ).not.toHaveBeenCalled()
				expect( view_a.display ).not.toHaveBeenCalled()
				expect( view_a._unrender ).not.toHaveBeenCalled()
				expect( view_a.dispose ).not.toHaveBeenCalled()

				expect( view_b._render ).not.toHaveBeenCalled()
				expect( view_b.display ).not.toHaveBeenCalled()
				expect( view_b._unrender.calls.count() ).toBe( 1 )
				expect( view_b.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Basic Nested Usage", ->
			view = null
			parent_view = null
			element = null

			hello_world_template = "Hello World"
			parent_template = "<div data-bind='view: $view.child_view'></div>"

			it "Setup", ->

				MockHelper.makeElement("template")
				          .setId("hello_world")
				          .html("Hello World")
				          .addToDOM()
			#END setup

			it "Should setup the view binding properly with a basic view", ->
				view = MockHelper.makeView("#hello_world", {template: hello_world_template})
				parent_view = MockHelper.makeView("#parent_template", {template: parent_template})
				parent_view.child_view = view

				element = MockHelper.makeElement()
				                    .bindings("view: view")
				                    .addToDOM()
				                    .andApply({
				                    	view: parent_view
				                    })

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( parent_view._render.calls.count() ).toBe( 1 )
				expect( parent_view.display.calls.count() ).toBe( 1 )
				expect( parent_view._unrender ).not.toHaveBeenCalled()
				expect( parent_view.dispose ).not.toHaveBeenCalled()

				expect( view._render.calls.count() ).toBe( 1 )
				expect( view.display.calls.count() ).toBe( 1 )
				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				parent_view.resetSpies()
				view.resetSpies()
			#END it

			it "Should unrender properly when removed from the DOM", ->
				element.removeFromDOM()

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()
				
				expect( parent_view._render ).not.toHaveBeenCalled()
				expect( parent_view.display ).not.toHaveBeenCalled()
				expect( parent_view._unrender.calls.count() ).toBe( 1 )
				expect( parent_view.dispose.calls.count() ).toBe( 1 )

				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()
				expect( view._unrender.calls.count() ).toBe( 1 )
				expect( view.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Basic Nested Observable Usage", ->
			obs = ko.observable()
			element = null
			view_a = view_b = null

			hello_world_template = "Hello World"
			foo_bar_template = "Foo Bar"
			parent_template = "<div data-bind='view: $view.child_view'></div>"

			it "Should apply blank observable properly", ->
				element = MockHelper.makeElement()
				                    .bindings("view: obs")
				                    .addToDOM()
				                    .andApply({obs})

				expect( ko.virtualElements.emptyNode.calls.count() ).toBe( 1 )
				expect( ko.virtualElements.emptyNode ).toHaveBeenCalledWith( element )

				expect( element.innerHTML ).toBe( "" )
			#END it

			it "Should update the template when a valid view with template is given", ->
				view_a = MockHelper.makeView("#parent_template", {template: parent_template})
				view_a.child_view = MockHelper.makeView("#hello_world", {template: hello_world_template})

				obs( view_a )

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render.calls.count() ).toBe( 1 )
				expect( view_a.display.calls.count() ).toBe( 1 )
				expect( view_a._unrender ).not.toHaveBeenCalled()
				expect( view_a.dispose ).not.toHaveBeenCalled()

				expect( view_a.child_view._render.calls.count() ).toBe( 1 )
				expect( view_a.child_view.display.calls.count() ).toBe( 1 )
				expect( view_a.child_view._unrender ).not.toHaveBeenCalled()
				expect( view_a.child_view.dispose ).not.toHaveBeenCalled()

				view_a.resetSpies()
				view_a.child_view.resetSpies()
			#END it

			it "Should swap views properly", ->
				view_b = MockHelper.makeView("#parent_template", {template: parent_template})
				view_b.child_view = MockHelper.makeView("#foo_bar", {template: foo_bar_template})

				obs( view_b )

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render ).not.toHaveBeenCalled()
				expect( view_a.display ).not.toHaveBeenCalled()
				expect( view_a._unrender.calls.count() ).toBe( 1 )
				expect( view_a.dispose.calls.count() ).toBe( 1 )

				expect( view_a.child_view._render ).not.toHaveBeenCalled()
				expect( view_a.child_view.display ).not.toHaveBeenCalled()
				expect( view_a.child_view._unrender.calls.count() ).toBe( 1 )
				expect( view_a.child_view.dispose.calls.count() ).toBe( 1 )

				expect( view_b._render.calls.count() ).toBe( 1 )
				expect( view_b.display.calls.count() ).toBe( 1 )
				expect( view_b._unrender ).not.toHaveBeenCalled()
				expect( view_b.dispose ).not.toHaveBeenCalled()

				expect( view_b.child_view._render.calls.count() ).toBe( 1 )
				expect( view_b.child_view.display.calls.count() ).toBe( 1 )
				expect( view_b.child_view._unrender ).not.toHaveBeenCalled()
				expect( view_b.child_view.dispose ).not.toHaveBeenCalled()

				view_a.resetSpies()
				view_a.child_view.resetSpies()
				view_b.resetSpies()
				view_b.child_view.resetSpies()
			#END it

			it "Should unrender properly when removed from the DOM", ->
				element.removeFromDOM()

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render ).not.toHaveBeenCalled()
				expect( view_a.display ).not.toHaveBeenCalled()
				expect( view_a._unrender ).not.toHaveBeenCalled()
				expect( view_a.dispose ).not.toHaveBeenCalled()

				expect( view_a.child_view._render ).not.toHaveBeenCalled()
				expect( view_a.child_view.display ).not.toHaveBeenCalled()
				expect( view_a.child_view._unrender ).not.toHaveBeenCalled()
				expect( view_a.child_view.dispose ).not.toHaveBeenCalled()

				expect( view_b._render ).not.toHaveBeenCalled()
				expect( view_b.display ).not.toHaveBeenCalled()
				expect( view_b._unrender.calls.count() ).toBe( 1 )
				expect( view_b.dispose.calls.count() ).toBe( 1 )

				expect( view_b.child_view._render ).not.toHaveBeenCalled()
				expect( view_b.child_view.display ).not.toHaveBeenCalled()
				expect( view_b.child_view._unrender.calls.count() ).toBe( 1 )
				expect( view_b.child_view.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Basic Nested Comment Usage", ->
			view = null
			parent_view = null
			comment = null

			hello_world_template = "Hello World"
			parent_template = "<div data-bind='view: $view.child_view'></div>"

			it "Should setup the view binding properly with a basic view", ->
				view = MockHelper.makeView("#hello_world", {template: hello_world_template})
				parent_view = MockHelper.makeView("#parent_template", {template: parent_template})
				parent_view.child_view = view

				comment = MockHelper.makeCommentBinding("view: view")
				                    .addToDOM()
				                    .andApply({
				                    	view: parent_view
				                    })

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( parent_view._render.calls.count() ).toBe( 1 )
				expect( parent_view.display.calls.count() ).toBe( 1 )
				expect( parent_view._unrender ).not.toHaveBeenCalled()
				expect( parent_view.dispose ).not.toHaveBeenCalled()

				expect( view._render.calls.count() ).toBe( 1 )
				expect( view.display.calls.count() ).toBe( 1 )
				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				parent_view.resetSpies()
				view.resetSpies()
			#END it

			it "Should unrender properly when removed from the DOM", ->
				comment.removeFromDOM()

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()
				
				expect( parent_view._render ).not.toHaveBeenCalled()
				expect( parent_view.display ).not.toHaveBeenCalled()
				expect( parent_view._unrender.calls.count() ).toBe( 1 )
				expect( parent_view.dispose.calls.count() ).toBe( 1 )

				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()
				expect( view._unrender.calls.count() ).toBe( 1 )
				expect( view.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Basic Nested Comment Observable Usage", ->
			obs = ko.observable()
			comment = null
			view_a = view_b = null

			parent_template = "<div data-bind='view: $view.child_view'></div>"
			hello_world_template = "Hello World"
			foo_bar_template = "Foo Bar"

			it "Should apply blank observable properly", ->
				comment = MockHelper.makeCommentBinding("view: obs")
				                    .addToDOM()
				                    .andApply({obs})

				expect( ko.virtualElements.emptyNode.calls.count() ).toBe( 1 )
				expect( ko.virtualElements.emptyNode ).toHaveBeenCalledWith( comment.start_comment )
			#END it

			it "Should update the template when a valid view with template is given", ->
				view_a = MockHelper.makeView("#parent_template", {template: parent_template})
				view_a.child_view = MockHelper.makeView("#hello_world", {template: hello_world_template})

				obs( view_a )

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render.calls.count() ).toBe( 1 )
				expect( view_a.display.calls.count() ).toBe( 1 )
				expect( view_a._unrender ).not.toHaveBeenCalled()
				expect( view_a.dispose ).not.toHaveBeenCalled()

				expect( view_a.child_view._render.calls.count() ).toBe( 1 )
				expect( view_a.child_view.display.calls.count() ).toBe( 1 )
				expect( view_a.child_view._unrender ).not.toHaveBeenCalled()
				expect( view_a.child_view.dispose ).not.toHaveBeenCalled()

				view_a.resetSpies()
				view_a.child_view.resetSpies()
			#END it

			it "Should swap views properly", ->
				view_b = MockHelper.makeView("#parent_template", {template: parent_template})
				view_b.child_view = MockHelper.makeView("#foo_bar", {template: foo_bar_template})

				obs( view_b )

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render ).not.toHaveBeenCalled()
				expect( view_a.display ).not.toHaveBeenCalled()
				expect( view_a._unrender.calls.count() ).toBe( 1 )
				expect( view_a.dispose.calls.count() ).toBe( 1 )

				expect( view_a.child_view._render ).not.toHaveBeenCalled()
				expect( view_a.child_view.display ).not.toHaveBeenCalled()
				expect( view_a.child_view._unrender.calls.count() ).toBe( 1 )
				expect( view_a.child_view.dispose.calls.count() ).toBe( 1 )

				expect( view_b._render.calls.count() ).toBe( 1 )
				expect( view_b.display.calls.count() ).toBe( 1 )
				expect( view_b._unrender ).not.toHaveBeenCalled()
				expect( view_b.dispose ).not.toHaveBeenCalled()

				expect( view_b.child_view._render.calls.count() ).toBe( 1 )
				expect( view_b.child_view.display.calls.count() ).toBe( 1 )
				expect( view_b.child_view._unrender ).not.toHaveBeenCalled()
				expect( view_b.child_view.dispose ).not.toHaveBeenCalled()

				view_a.resetSpies()
				view_a.child_view.resetSpies()
				view_b.resetSpies()
				view_b.child_view.resetSpies()
			#END it

			it "Should unrender properly when removed from the DOM", ->
				comment.removeFromDOM()

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view_a._render ).not.toHaveBeenCalled()
				expect( view_a.display ).not.toHaveBeenCalled()
				expect( view_a._unrender ).not.toHaveBeenCalled()
				expect( view_a.dispose ).not.toHaveBeenCalled()

				expect( view_a.child_view._render ).not.toHaveBeenCalled()
				expect( view_a.child_view.display ).not.toHaveBeenCalled()
				expect( view_a.child_view._unrender ).not.toHaveBeenCalled()
				expect( view_a.child_view.dispose ).not.toHaveBeenCalled()

				expect( view_b._render ).not.toHaveBeenCalled()
				expect( view_b.display ).not.toHaveBeenCalled()
				expect( view_b._unrender.calls.count() ).toBe( 1 )
				expect( view_b.dispose.calls.count() ).toBe( 1 )

				expect( view_b.child_view._render ).not.toHaveBeenCalled()
				expect( view_b.child_view.display ).not.toHaveBeenCalled()
				expect( view_b.child_view._unrender.calls.count() ).toBe( 1 )
				expect( view_b.child_view.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Nest Views in Observable Arrays with Element Bindings", ->
			element = null
			obsArr = ko.observableArray([])
			parent_view = null
			child_view = null

			parent_template = "<div data-bind='view: $view.child_view'></div>"
			hello_world_template = "Hello World"

			beforeEach ->
				parent_view?.resetSpies()
				child_view?.resetSpies()
			#END beforeEach

			it "Should set up properly", ->
				element = MockHelper.makeElement()
				                    .bindings("foreach: obsArr")
				                    .html("<div data-bind='view: $data'></div>")
				                    .addToDOM()
				                    .andApply({obsArr})
				
				parent_view = MockHelper.makeView("#parent_template", {
					template: parent_template
					defaults:
						'child_view': ->
							child_view = MockHelper.makeView("#hello_world", {
								template: hello_world_template
							})
							return child_view
						#END child_view
					#END defaults
				})

				expect( parent_view._render ).not.toHaveBeenCalled()
				expect( parent_view.display ).not.toHaveBeenCalled()
				expect( parent_view._unrender ).not.toHaveBeenCalled()
				expect( parent_view.dispose ).not.toHaveBeenCalled()

				expect( child_view._render ).not.toHaveBeenCalled()
				expect( child_view.display ).not.toHaveBeenCalled()
				expect( child_view._unrender ).not.toHaveBeenCalled()
				expect( child_view.dispose ).not.toHaveBeenCalled()
			#END it

			it "Should call the correct display and dispose methods of sub views", ->
				obsArr.push( parent_view )

				expect( parent_view._render.calls.count() ).toBe( 1 )
				expect( parent_view.display.calls.count() ).toBe( 1 )
				expect( parent_view._unrender ).not.toHaveBeenCalled()
				expect( parent_view.dispose ).not.toHaveBeenCalled()

				expect( child_view._render.calls.count() ).toBe( 1 )
				expect( child_view.display.calls.count() ).toBe( 1 )
				expect( child_view._unrender ).not.toHaveBeenCalled()
				expect( child_view.dispose ).not.toHaveBeenCalled()
			#END it

			it "Should call the correct display and dispose methods of the sub views when removed", ->
				obsArr([])

				expect( parent_view._render ).not.toHaveBeenCalled()
				expect( parent_view.display ).not.toHaveBeenCalled()
				expect( parent_view._unrender.calls.count() ).toBe( 1 )
				expect( parent_view.dispose.calls.count() ).toBe( 1 )

				expect( child_view._render ).not.toHaveBeenCalled()
				expect( child_view.display ).not.toHaveBeenCalled()
				expect( child_view._unrender.calls.count() ).toBe( 1 )
				expect( child_view.dispose.calls.count() ).toBe( 1 )
			#END it

			it "Teardown", ->
				element.removeFromDOM()
				Falcon.templateAdapter.resetCache()
			#END it
		#END describe

		describe "Observable updates in display", ->
			view = null
			element = null

			it "Should setup the view binding properly with a basic view", ->
				view = MockHelper.makeView("#hello_world", {
					template: "Hello World"
					observables:
						'is_visible': false
					#END observables

					display: ->
						return @ if @is_visible()
					#END display
				})

				element = MockHelper.makeElement()
				                    .bindings("view: view")
				                    .addToDOM()
				                    .andApply({view})

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view._render.calls.count() ).toBe( 1 )
				expect( view.display.calls.count() ).toBe( 1 )

				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("Hello World")

				view.resetSpies()
			#END it

			it "Should not re-execute when an observable that's in the display method is updated", ->
				view.is_visible(true)

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()
				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("Hello World")

				view.resetSpies()
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Observable updates in dispose", ->
			view = null
			obs = null
			element = null

			it "Setup", ->
				view = MockHelper.makeView("#hello_world", {
					template: "Hello World"
					observables:
						'is_disposed': false
					#END observables

					dispose: ->
						return @ if @is_disposed()
					#END dispose
				})
				
				obs = ko.observable(view)

				element = MockHelper.makeElement()
				                    .bindings("view: obs")
				                    .addToDOM()
				                    .andApply({obs})

				view.resetSpies()
			#END setup

			it "Should setup the view binding properly with a basic view", ->
				obs(null)

				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()
				expect( view._unrender.calls.count() ).toBe( 1 )
				expect( view.dispose.calls.count() ).toBe( 1 )

				view.resetSpies()
			#END it

			it "Should not re-execute when an observable that's in the display method is updated", ->
				view.is_disposed(true)

				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()
				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				view.resetSpies()
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Observable updates in display", ->
			view = null
			element = null

			it "Setup", ->
				hello_world = MockHelper.makeElement("template")
				                        .setId("hello_world")
				                        .html("Hello World")
				                        .addToDOM()
			#END setup

			it "Should setup the view binding properly with a basic view", ->
				view = MockHelper.makeView("#hello_world", {
					template: "Hello World"
					observables:
						'is_visible': false
					#END observables

					display: ->
						return @ if @is_visible()
					#END display
				})

				element = MockHelper.makeElement()
				                    .bindings("view: view")
				                    .addToDOM()
				                    .andApply({view})

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view._render.calls.count() ).toBe( 1 )
				expect( view.display.calls.count() ).toBe( 1 )

				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("Hello World")

				view.resetSpies()
			#END it

			it "Should not re-execute when an observable that's in the display method is updated", ->
				view.is_visible(true)

				expect( ko.virtualElements.emptyNode ).not.toHaveBeenCalled()

				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()
				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				expect( element.innerHTML ).toBe("Hello World")

				view.resetSpies()
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe

		describe "Observable updates in dispose", ->
			view = null
			obs = null
			element = null

			it "Setup", ->
				view = MockHelper.makeView("#hello_world", {
					template: "Hello World"

					observables:
						'is_disposed': false
					#END observables

					dispose: ->
						return @ if @is_disposed()
					#END dispose
				})
				
				obs = ko.observable(view)

				element = MockHelper.makeElement()
				                    .bindings("view: obs")
				                    .addToDOM()
				                    .andApply({obs})

				view.resetSpies()
			#END setup

			it "Should setup the view binding properly with a basic view", ->
				obs(null)

				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()
				expect( view._unrender.calls.count() ).toBe( 1 )
				expect( view.dispose.calls.count() ).toBe( 1 )

				view.resetSpies()
			#END it

			it "Should not re-execute when an observable that's in the display method is updated", ->
				view.is_disposed(true)

				expect( view._render ).not.toHaveBeenCalled()
				expect( view.display ).not.toHaveBeenCalled()
				expect( view._unrender ).not.toHaveBeenCalled()
				expect( view.dispose ).not.toHaveBeenCalled()

				view.resetSpies()
			#END it

			it "Teardown", -> Falcon.templateAdapter.resetCache()
		#END describe
	#END describe

	describe "foreach", ->
		foreach_binding = null

		beforeEach ->
			foreach_binding ?= Falcon.__binding__original_foreach__

			spyOn( foreach_binding, 'init' ).and.callThrough()
			spyOn( foreach_binding, 'update' ).and.callThrough()
		#END beforeEach

		describe "Basic Array", ->
			items = null
			afterAdd = beforeRemove = afterRender = null

			setupSpies = ->
				afterAdd = jasmine.createSpy("afterAdd")
				beforeRemove = jasmine.createSpy("beforeRemove").and.callFake ( element )->
					element.parentNode?.removeChild(element)
				#END beforeRemove
				afterRender = jasmine.createSpy("afterRender")
			#END setupSpies

			beforeEach ->
				items = [
					{text: "Hello World"}
					{text: "Foo Bar"}
					{text: "Free Bird"}
				]

				afterAdd?.calls.reset()
				beforeRemove?.calls.reset()
				afterRender?.calls.reset()
			#END beforeEach

			it "Should bind properly against an array", ->
				element = MockHelper.makeElement("ul")
				                    .bindings("foreach: items")
				                    .html("<li data-bind='text: text'></li>")
				                    .andApply({items})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( foreach_binding.init.calls.count() ).toBe( 1 )
				expect( foreach_binding.update.calls.count() ).toBe( 1 )
			#END it

			it "Should bind properly against an array with an expanded binding defintiion", ->
				setupSpies()

				element = MockHelper.makeElement("ul")
				                    .bindings("foreach: {
				                    	data: items,
				                    	afterAdd: afterAdd,
				                    	beforeRemove: beforeRemove,
				                    	afterRender: afterRender
				                    }")
				                    .html("<li data-bind='text: text'></li>")
				                    .andApply({items, afterAdd, beforeRemove, afterRender})

				expect( element.childNodes.length ).toBe( 3 )
				
				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( afterAdd ).not.toHaveBeenCalled()
				expect( afterRender.calls.count() ).toBe( 3 )
				expect( beforeRemove ).not.toHaveBeenCalled()

				expect( foreach_binding.init.calls.count() ).toBe( 1 )
				expect( foreach_binding.update.calls.count() ).toBe( 1 )
			#END it
		#END describe

		describe "Observable Array", ->
			items = null
			element = null
			afterAdd = beforeRemove = afterRender = null

			setupItems = ->
				items = ko.observableArray([
					{text: "Hello World"}
					{text: "Foo Bar"}
					{text: "Free Bird"}
				])
			#END setupItems

			setupSpies = ->
				afterAdd = jasmine.createSpy("afterAdd")
				beforeRemove = jasmine.createSpy("beforeRemove").and.callFake ( element )->
					element.parentNode?.removeChild(element)
				#END beforeRemove
				afterRender = jasmine.createSpy("afterRender")
			#END setupSpies

			beforeEach ->
				afterAdd?.calls.reset()
				beforeRemove?.calls.reset()
				afterRender?.calls.reset()
			#END beforeEach

			it "Should bind properly against an array", ->
				setupItems()

				element = MockHelper.makeElement("ul")
				                    .bindings("foreach: items")
				                    .html("<li data-bind='text: text'></li>")
				                    .andApply({items})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( foreach_binding.init.calls.count() ).toBe( 1 )
				expect( foreach_binding.update.calls.count() ).toBe( 1 )
			#END it

			it "Should remove elements", ->
				items.pop()
				items.pop()

				expect( element.childNodes.length ).toBe( 1 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")

				expect( foreach_binding.init.calls.count() ).toBe( 0 )
				expect( foreach_binding.update.calls.count() ).toBe( 2 )
			#END it

			it "Should add elements", ->
				items.push({text: "Qux"})
				items.push({text: "Quux"})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Qux")
				expect( element.childNodes[2].innerText ).toBe("Quux")

				expect( foreach_binding.init.calls.count() ).toBe( 0 )
				expect( foreach_binding.update.calls.count() ).toBe( 2 )
			#END it

			it "Should bind properly against an array with an expanded binding defintiion", ->
				setupItems()
				setupSpies()

				element = MockHelper.makeElement("ul")
				                    .bindings("foreach: {
				                    	data: items,
				                    	afterAdd: afterAdd,
				                    	beforeRemove: beforeRemove,
				                    	afterRender: afterRender
				                    }")
				                    .html("<li data-bind='text: text'></li>")
				                    .andApply({items, afterAdd, beforeRemove, afterRender})

				expect( element.childNodes.length ).toBe( 3 )
				
				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( afterAdd ).not.toHaveBeenCalled()
				expect( afterRender.calls.count() ).toBe( 3 )
				expect( beforeRemove ).not.toHaveBeenCalled()

				expect( foreach_binding.init.calls.count() ).toBe( 1 )
				expect( foreach_binding.update.calls.count() ).toBe( 1 )
			#END it

			it "Should remove elements with expanded definition", ->
				items.pop()
				items.pop()

				expect( element.childNodes.length ).toBe( 1 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")

				expect( afterAdd ).not.toHaveBeenCalled()
				expect( afterRender ).not.toHaveBeenCalled()
				expect( beforeRemove.calls.count() ).toBe( 2 )

				expect( foreach_binding.init.calls.count() ).toBe( 0 )
				expect( foreach_binding.update.calls.count() ).toBe( 2 )
			#END it

			it "Should add elements with expanded definition", ->
				items.push({text: "Qux"})
				items.push({text: "Quux"})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Qux")
				expect( element.childNodes[2].innerText ).toBe("Quux")

				expect( afterAdd.calls.count() ).toBe( 2 )
				expect( afterRender.calls.count() ).toBe( 2 )
				expect( beforeRemove ).not.toHaveBeenCalled()

				expect( foreach_binding.init.calls.count() ).toBe( 0 )
				expect( foreach_binding.update.calls.count() ).toBe( 2 )
			#END it
		#END describe

		describe "Collection", ->
			class TestModel extends Falcon.Model
			class TestCollection extends Falcon.Collection
				model: TestModel
			#END TestCollection

			items = null
			element = null
			afterAdd = beforeRemove = afterRender = null

			setupItems = ->
				items = new TestCollection([
					new TestModel({text: "Hello World"})
					new TestModel({text: "Foo Bar"})
					new TestModel({text: "Free Bird"})
				])
			#END setupItems

			setupSpies = ->
				afterAdd = jasmine.createSpy("afterAdd")
				beforeRemove = jasmine.createSpy("beforeRemove").and.callFake ( element )->
					element.parentNode?.removeChild(element)
				#END beforeRemove
				afterRender = jasmine.createSpy("afterRender")
			#END setupSpies

			beforeEach ->
				afterAdd?.calls.reset()
				beforeRemove?.calls.reset()
				afterRender?.calls.reset()
			#END beforeEach

			it "Should bind properly against an collection", ->
				setupItems()

				element = MockHelper.makeElement("ul")
				                    .bindings("foreach: items")
				                    .html("<li data-bind='text: text'></li>")
				                    .andApply({items})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( foreach_binding.init.calls.count() ).toBe( 1 )
				expect( foreach_binding.update.calls.count() ).toBe( 1 )
			#END it

			it "Should remove elements", ->
				items.pop()
				items.pop()

				expect( element.childNodes.length ).toBe( 1 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")

				expect( foreach_binding.init.calls.count() ).toBe( 0 )
				expect( foreach_binding.update.calls.count() ).toBe( 2 )
			#END it

			it "Should add elements", ->
				items.push(new TestModel({text: "Qux"}))
				items.push(new TestModel({text: "Quux"}))

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Qux")
				expect( element.childNodes[2].innerText ).toBe("Quux")

				expect( foreach_binding.init.calls.count() ).toBe( 0 )
				expect( foreach_binding.update.calls.count() ).toBe( 2 )
			#END it

			it "Should bind properly against an collection with an expanded binding defintiion", ->
				setupItems()
				setupSpies()

				element = MockHelper.makeElement("ul")
				                    .bindings("foreach: {
				                    	data: items,
				                    	afterAdd: afterAdd,
				                    	beforeRemove: beforeRemove,
				                    	afterRender: afterRender
				                    }")
				                    .html("<li data-bind='text: text'></li>")
				                    .andApply({items, afterAdd, beforeRemove, afterRender})

				expect( element.childNodes.length ).toBe( 3 )
				
				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( afterAdd ).not.toHaveBeenCalled()
				expect( afterRender.calls.count() ).toBe( 3 )
				expect( beforeRemove ).not.toHaveBeenCalled()

				expect( foreach_binding.init.calls.count() ).toBe( 1 )
				expect( foreach_binding.update.calls.count() ).toBe( 1 )
			#END it

			it "Should remove elements with expanded definition", ->
				items.pop()
				items.pop()

				expect( element.childNodes.length ).toBe( 1 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")

				expect( afterAdd ).not.toHaveBeenCalled()
				expect( afterRender ).not.toHaveBeenCalled()
				expect( beforeRemove.calls.count() ).toBe( 2 )

				expect( foreach_binding.init.calls.count() ).toBe( 0 )
				expect( foreach_binding.update.calls.count() ).toBe( 2 )
			#END it

			it "Should add elements with expanded definition", ->
				items.push(new TestModel({text: "Qux"}))
				items.push(new TestModel({text: "Quux"}))

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Qux")
				expect( element.childNodes[2].innerText ).toBe("Quux")

				expect( afterAdd.calls.count() ).toBe( 2 )
				expect( afterRender.calls.count() ).toBe( 2 )
				expect( beforeRemove ).not.toHaveBeenCalled()

				expect( foreach_binding.init.calls.count() ).toBe( 0 )
				expect( foreach_binding.update.calls.count() ).toBe( 2 )
			#END it
		#END it
	#END describe

	describe "options", ->
		options_binding = null

		beforeEach ->
			options_binding ?= Falcon.__binding__original_options__

			spyOn( options_binding, 'init').and.callThrough()
			spyOn( options_binding, 'update').and.callThrough()
		#END beforeEach

		describe "Basic Array", ->
			items = null

			beforeEach ->
				items = [
					{text: "Hello World"}
					{text: "Foo Bar"}
					{text: "Free Bird"}
				]
			#END beforeEach

			it "Should bind properly against an array", ->
				element = MockHelper.makeElement("select")
				                    .bindings("options: items, optionsText: 'text'")
				                    .andApply({items})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( options_binding.init.calls.count() ).toBe( 1 )
				expect( options_binding.update.calls.count() ).toBe( 1 )
			#END it
		#END describe

		describe "Observable Array", ->
			items = null
			element = null

			setupItems = ->
				items = ko.observableArray([
					{text: "Hello World"}
					{text: "Foo Bar"}
					{text: "Free Bird"}
				])
			#END setupItems

			it "Should bind properly against an array", ->
				setupItems()

				element = MockHelper.makeElement("select")
				                    .bindings("options: items, optionsText: 'text'")
				                    .andApply({items})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( options_binding.init.calls.count() ).toBe( 1 )
				expect( options_binding.update.calls.count() ).toBe( 1 )
			#END it

			it "Should remove elements", ->
				items.pop()
				items.pop()

				expect( element.childNodes.length ).toBe( 1 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")

				expect( options_binding.init.calls.count() ).toBe( 0 )
				expect( options_binding.update.calls.count() ).toBe( 2 )
			#END it

			it "Should add elements", ->
				items.push({text: "Qux"})
				items.push({text: "Quux"})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Qux")
				expect( element.childNodes[2].innerText ).toBe("Quux")

				expect( options_binding.init.calls.count() ).toBe( 0 )
				expect( options_binding.update.calls.count() ).toBe( 2 )
			#END it
		#END describe

		describe "Collection", ->
			class TestModel extends Falcon.Model
			class TestCollection extends Falcon.Collection
				model: TestModel
			#END TestCollection

			items = null
			element = null

			setupItems = ->
				items = new TestCollection([
					new TestModel({text: "Hello World"})
					new TestModel({text: "Foo Bar"})
					new TestModel({text: "Free Bird"})
				])
			#END setupItems

			it "Should bind properly against an collection", ->
				setupItems()

				element = MockHelper.makeElement("select")
				                    .bindings("options: items, optionsText: 'text'")
				                    .andApply({items})

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Foo Bar")
				expect( element.childNodes[2].innerText ).toBe("Free Bird")

				expect( options_binding.init.calls.count() ).toBe( 1 )
				expect( options_binding.update.calls.count() ).toBe( 1 )
			#END it

			it "Should remove elements", ->
				items.pop()
				items.pop()

				expect( element.childNodes.length ).toBe( 1 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")

				expect( options_binding.init.calls.count() ).toBe( 0 )
				expect( options_binding.update.calls.count() ).toBe( 2 )
			#END it

			it "Should add elements", ->
				items.push(new TestModel({text: "Qux"}))
				items.push(new TestModel({text: "Quux"}))

				expect( element.childNodes.length ).toBe( 3 )

				expect( element.childNodes[0].innerText ).toBe("Hello World")
				expect( element.childNodes[1].innerText ).toBe("Qux")
				expect( element.childNodes[2].innerText ).toBe("Quux")

				expect( options_binding.init.calls.count() ).toBe( 0 )
				expect( options_binding.update.calls.count() ).toBe( 2 )
			#END it
		#END it
	#END describe

	describe "log", ->
		describe "Bound to Element", ->
			element = null
			obs = ko.observable("Foo Bar")

			beforeEach ->
				spyOn(console, 'log')
			#END beforeEach

			it "Should log properly with basic value", ->
				element = MockHelper.makeElement("div")
				                    .bindings("log: value")
				                    .andApply({value: "Hello World"})

				expect( console.log.calls.count() ).toBe( 1 )
				expect( console.log ).toHaveBeenCalledWith("Hello World")
			#END it

			it "Should log properly with an observable value", ->
				element = MockHelper.makeElement("div")
				                    .bindings("log: value")
				                    .andApply({value: obs})

				expect( console.log.calls.count() ).toBe( 1 )
				expect( console.log ).toHaveBeenCalledWith("Foo Bar")
			#END it

			it "Should change value", ->
				obs("Free Bird")

				expect( console.log.calls.count() ).toBe( 1 )
				expect( console.log ).toHaveBeenCalledWith("Free Bird")
			#END it
		#END describe

		describe "Bound to Comment", ->
			element = null
			obs = ko.observable("Foo Bar")

			beforeEach ->
				spyOn(console, 'log')
			#END beforeEach

			it "Should log properly with basic value", ->
				element = MockHelper.makeCommentBinding("log: value")
				                    .andApply({value: "Hello World"})

				expect( console.log.calls.count() ).toBe( 1 )
				expect( console.log ).toHaveBeenCalledWith("Hello World")
			#END it

			it "Should log properly with an observable value", ->
				element = MockHelper.makeCommentBinding("log: value")
				                    .andApply({value: obs})

				expect( console.log.calls.count() ).toBe( 1 )
				expect( console.log ).toHaveBeenCalledWith("Foo Bar")
			#END it

			it "Should change value", ->
				obs("Free Bird")

				expect( console.log.calls.count() ).toBe( 1 )
				expect( console.log ).toHaveBeenCalledWith("Free Bird")
			#END it
		#END describe
	#END describe
#END describe