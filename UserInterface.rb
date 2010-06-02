#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.01.2010
 
class Hud
	def initialize
		
	end
	
	def update
		
	end
	
	def draw
		
	end
end

#This class renders the overlay which shows the position of tracked entities
#	In order to render this effect is psudo-perspective without a global perspective warp,
#	render the tracking blips along an elipse which simulates a circle in perpective.
#
#	Calculate an elipse and project the rendering of the blip onto it.
#	Calculate the position of the blip by getting the angle between the player and the entity
#	to be tracked.
class Tracking_Overlay
	def initialize(player)
		@player = player
		@tracked = Array.new
		@blips = Array.new
	end
	
	def track(entity)
		@tracked << entity
	end
	
	def untrack(entity)
		#Remove from @tracked
		@tracked.delete_if {|e| e == entity}
	end
	
	def update
		@tracked.each do |entity|
			
		end
	end
	
	def draw
		
	end
	
	private
	
	def add_blip(entity)
		
	end
	
	def remove_blip
		
	end
end
