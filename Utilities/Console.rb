#!/usr/bin/ruby

#This class should reroute standard out and display it in a
#text box on screen.  This way, errors etc can be displayed
#in engine.
class GosuConsole
	def initialize
		@output = TextBox.new($window.width, 200)
	end
	
	def puts(*args)
		@output.puts args
	end
end
