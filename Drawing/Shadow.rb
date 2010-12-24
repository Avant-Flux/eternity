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
							{:factor_x => @scale, :factor_y => @scale, :color => @color})
		end
		
		private
		
		def color
			#~ Calculate the color of the shadow to be rendered, and mix in
			#~ The correct opacity
			color = 0x0000FF
			color += opacity * 0x1000000 #Shift the opacity to the correct place value in hex
		end
		
		def opacity
			percent = 0.2
			0xFF * percent	#Convert the percent to a two-digit hex value
		end
		
		def scale
			#~ Calculate the amount by which to scale the shadow
			
			#~ 1
			(@entity.z - @entity.elevation + 1)
		end
end
