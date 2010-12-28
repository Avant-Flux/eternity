#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require './Drawing/GosuPatch'

# Handles the drawing of simple shadows.
class Shadow
	OPACITY_CONSTANT = 0.8

	def initialize(entity, circle)
		@entity = entity
		@circle = circle
	end
	
	def update
		@color = color
		@scale = scale
	end
	
	def draw
		@circle.draw_centered(@entity.x, @entity.y, @entity.elevation, 
						:factor_x => @scale, :factor_y => @scale, 
						:offset_z => -1, :color => @color)
	end
	
	private
	
	# Calculate the color of the shadow to be rendered, and mix in
	# the correct opacity
	def color
		color = 0x0000FF		#Current the shadows are blue for testing purposes
		color += opacity << 24	#Shift the opacity to the correct place value in hex
	end
	
	# Determine the value of the alpha channel.
	def opacity
		#Calculate the difference between the terrain and the entity.
		height = (@entity.z - @entity.elevation)
		height = 1 if height < 1
		
		#Compute a percent based on the inverse-square of the distance
		#and a constant which determines the base opacity.
		percent = OPACITY_CONSTANT/(height**2)
		
		#Convert the percent to a two-digit hex value
		output = (0xFF * percent).to_i
		#~ puts output.to_s 16
		
		return output
	end
	
	# Calculate the amount by which to scale the shadow
	def scale
		(@entity.z - @entity.elevation + 1)
	end
end
