#!/usr/bin/ruby

#This class should reroute standard out and display it in a
#text box on screen.  This way, errors etc can be displayed
#in engine.
class GosuConsole < TextBox
	def initialize(pos=[0,0,0], percent_of_height)
		super(pos, $window.width, ($window.height*percent_of_height/100.0).round, nil)
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
