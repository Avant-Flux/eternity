#!/usr/bin/ruby

#This class should reroute standard out and display it in a
#text box on screen.  This way, errors etc can be displayed
#in engine.
class GosuConsole < TextBox
	def initialize(pos, width, height)
		super(pos, width, height)
	end
	
	def printf(format_string, *args)
		Kernel.puts 1
		string = sprintf(format_string, *args)
		Kernel.puts 2
		@output.puts string
	end
	
	def draw
		@output.update
	end
end
