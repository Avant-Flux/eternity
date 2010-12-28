#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require './Drawing/GosuPatch'

class Shadow
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
		
		def color
			#~ Calculate the color of the shadow to be rendered, and mix in
			#~ The correct opacity
			color = 0x0000FF
			color += opacity << 24 #Shift the opacity to the correct place value in hex
		end
		
		def opacity
			height = (@entity.z - @entity.elevation)
			height = 1 if height <= 0
			percent = 1/(height**2)
			output = (0xFF * percent).to_i	#Convert the percent to a two-digit hex value
			#~ puts output.to_s 16
			
			#Limit the output to 0xFF
			output = 0xFF if output > 0xFF
			
			return output
		end
		
		def scale
			#~ Calculate the amount by which to scale the shadow
			
			#~ 1
			(@entity.z - @entity.elevation + 1)
		end
end
