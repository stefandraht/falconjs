# Building Falcon requires coffee-script and uglify-js. For
# help installing, try:
#
# `npm -g install coffee-script uglify-js`
#
# Original Cake file from Chosen.js - modified for our use
#   https://github.com/harvesthq/chosen/blob/master/Cakefile
fs              	= require 'fs'
path            	= require 'path'
{spawn, exec}   	= require 'child_process'
CoffeeScript    	= require 'coffee-script'
{parser, uglify}	= require 'uglify-js'


# Get the version number
version_file = 'VERSION'
version = "#{fs.readFileSync(version_file)}".replace /[^0-9a-zA-Z.]*/gm, ''
version_tag = -> "v#{version}"

compiledFiles = {
	"scripts/falcon.js": [
		"coffee/header.coffee"
		"coffee/utility.coffee"
		"coffee/falcon.coffee"
		"coffee/falcon.class.coffee"
		"coffee/falcon.model.coffee"
		"coffee/falcon.view.coffee"
		"coffee/falcon.collection.coffee"
		"coffee/falcon.ko.bindings.coffee"
		"coffee/falcon.ko.extenders.coffee"
	]

	"tests/tests.js": [
		"tests/tests.coffee"
	]
}

Array::unique = ->
	output = {}
	output[@[key]] = @[key] for key in [0...@length]
	value for key, value of output

# Method used to write a javascript file
write_javascript_file = (filename, body) ->
	body = body
		.replace(/\{\{VERSION\}\}/gi, version)
		.replace(/\{\{VERSION_TAG\}\}/gi, version_tag)
	fs.writeFileSync filename, body
	console.log "Wrote #{filename}"

# Task to build the current source
task 'build', 'build from source', build = (cb) ->
	code = minified_code = ""
	file_name = file_contents = ""
	try
		for destination, sources of compiledFiles
			file_name = destination
			file_contents += "#{fs.readFileSync(source)}\r\n" for source in sources	

			code = CoffeeScript.compile(file_contents)
			minified_code = parser.parse( code )
			minified_code = uglify.ast_mangle( minified_code )
			minified_code = uglify.ast_squeeze( minified_code )
			minified_code = uglify.gen_code( minified_code )

			write_javascript_file(file_name, code)
			write_javascript_file(file_name.replace(/\.js$/,'.min.js'), minified_code)

		cb() if typeof cb is 'function'
	catch e
		print_error e, file_name, file_contents

#Task to watch files (so they're built when saved)
task 'watch', 'watch coffee/ and tests/ for changes and build', ->
	console.log "Watching for changes in coffee/ and tests/"

	for destination, sources of compiledFiles
		for source in sources
			fs.watch( source, (curr, prev) ->
				console.log "Saw change in #{source}"
				invoke 'build'
			)

# --------------------------------------------------------
# 
# --------------------------------------------------------
run = (cmd, args, cb, err_cb) ->
	exec "#{cmd} #{args.join(' ')}", (err, stdout, stderr) ->
		if err isnt null
			console.error stderr

			if typeof err_cb is 'function'
				err_cb()
			else
				throw "Failed command execution (#{err})."
		else
			cb(stdout) if typeof cb is 'function'

# --------------------------------------------------------
# 
# --------------------------------------------------------
with_clean_repo = (cb) ->
	run 'git', ['diff', '--exit-code'], cb, ->
		throw 'There are files that need to be committed first.'

# --------------------------------------------------------
#
# --------------------------------------------------------
without_existing_tag = (cb) ->
	run 'git', ['tag'], (stdout) ->
		if stdout.split("\n").indexOf( version_tag() ) >= 0
			throw 'This tag has already been committed to the repo.'
		else
			cb()

# --------------------------------------------------------
#
# --------------------------------------------------------
push_repo = (args=[], cb, cb_err) ->
	run 'git', ['push'].concat(args), cb, cb_err

# --------------------------------------------------------
#
# --------------------------------------------------------
print_error = (error, file_name, file_contents) ->
	line = error.message.match /line ([0-9]+):/
	if line && line[1] && line = parseInt(line[1])
		contents_lines = file_contents.split "\n"
		first = if line-4 < 0 then 0 else line-4
		last  = if line+3 > contents_lines.size then contents_lines.size else line+3
		console.log "Error compiling #{file_name}. \"#{error.message}\"\n"
		index = 0
		for line in contents_lines[first...last]
			index++
			line_number = first + 1 + index
			console.log "#{(' ' for [0..(3-(line_number.toString().length))]).join('')} #{line}"
	else
		console.log "Error compiling #{file_name}: #{error.message}"

# --------------------------------------------------------
#
# --------------------------------------------------------
git_commit = (message) ->
	run "git", ["commit", '-a', '-m', message]

# --------------------------------------------------------
#
# --------------------------------------------------------
git_tag = (cb, cb_err) ->
	run 'git', ['tag', '-a', '-m', "\"Version #{version}\"", version_tag()], cb, cb_err

# --------------------------------------------------------
#
# --------------------------------------------------------
git_untag = (e) ->
	console.log "Failure to tag caught: #{e}"
	console.log "Removing tag #{version_tag()}"
	run 'git', ['tag', '-d', version_tag()]


# --------------------------------------------------------
#
# --------------------------------------------------------
task 'major', 'Executing a major version update', () ->

	console.log "Trying to run a major version update"

	v = version.match(/^([0-9]+)\.([0-9]+)\.([0-9]+)$/)
	v[1]++
	v[2] = v[3] = 0
	version = "#{v[1]}.#{v[2]}.#{v[3]}"

	fs.writeFileSync(version_file, version)

	invoke 'build'
	invoke 'build-tests'

	git_commit("\"Updating to Major version #{version}\"")

	git_tag(->)

	console.log "Finished updating major version"


# --------------------------------------------------------
#
# --------------------------------------------------------
task 'minor', 'Executing a minor version update', () ->

	console.log "Trying to run a minor versino update"

	v = version.match(/^([0-9]+)\.([0-9]+)\.([0-9]+)$/)
	v[2]++
	v[3] = 0
	version = "#{v[1]}.#{v[2]}.#{v[3]}"

	fs.writeFileSync(version_file, version)

	invoke 'build'
	invoke 'build-tests'

	git_commit("\"Updating to Minor version #{version}\"")

	git_tag(->)

	console.log "Finished updating minor version"


# --------------------------------------------------------
#
# --------------------------------------------------------
task 'patch', 'Executing a patch version update', () ->

	console.log "Trying to run a patch version update"

	v = version.match(/^([0-9]+)\.([0-9]+)\.([0-9]+)$/)
	v[3]++
	version = "#{v[1]}.#{v[2]}.#{v[3]}"

	fs.writeFileSync(version_file, version)

	invoke 'build'
	invoke 'build-tests'

	git_commit("\"Updating to Patch version #{version}\"")

	git_tag(->)

	console.log "Finished updating patch version"


# --------------------------------------------------------
#
# --------------------------------------------------------
task 'release', 'build, tag the current release, and push', ->
	console.log "Trying to tag #{version_tag()}..."
	with_clean_repo( ->
		without_existing_tag( ->
			build( ->
				git_tag ( ->
					push_repo [], ( ->
						push_repo ['--tags'], ( ->
							console.log "Successfully tagged #{version_tag()}: https://github.com/stoodder/falconjs/tree/#{version_tag()}"

						), git_untag
					), git_untag
				), git_untag
			)
		)
	)