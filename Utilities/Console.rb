#!/usr/bin/ruby

#This class should reroute standard out and display it in a
#text box on screen.  This way, errors etc can be displayed
#in engine.
class GosuConsole < TextBox
	TOP_BUFFER = 20

	def initialize(percent_of_height)
		super([0,TOP_BUFFER,0], $window.width, (($window.height-TOP_BUFFER)*percent_of_height/100.0).round, nil)
		@font = Gosu::Font.new($window, "Trebuchet MS", 20)
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
	
	def stop
		#Suspend output and clear output buffer
	end
	
	def clear_buffer
		
	end
	
	def draw
		super :z_offset => 1000
	end
end
