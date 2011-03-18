#!/usr/bin/ruby

#This class should reroute standard out and display it in a
#text box on screen.  This way, errors etc can be displayed
#in engine.
class GosuConsole < TextBox
	def initialize(pos, width, height)
		super(pos, width, height)
		@visible = true
	end
	
	def toggle_visibility
		@visible = !@visible
	end
	
	def visibility=(vis)
		@visible = vis
	end
	
	def visible?
		@visible
	end
	
	def pause
		#Temporarily suspend output
	end
	
	def printf(format_string, *args)
		string = sprintf(format_string, *args)
		puts string
	end
	
	def clear_buffer
		
	end
	
	def draw
		super :z_offset => 1000
	end
end
