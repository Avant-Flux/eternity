#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require './Drawing/GosuPatch'

class Shadow
	def initialize(radius)
		color = Gosu::Color::WHITE
		
		r2 = radius * 2
		
		@image = TexPlay.create_blank_image($window, r2+2, r2+2)
		@image.circle radius+1, radius+1, radius, :color => color, :fill => true
	end
	
	def update
		@color = color
		@scale = scale
	end
	
	def draw(x, y, z, elevation)
		@image.draw_centered x, y - elevation, z, @scale, @scale, @color
	end
	
	private
	
	def color
		#~ Calculate the color of the shadow to be rendered, and mix in
		#~ The correct opacity
		color = 0x0000FF
		color += opacity * 0x1000000
	end
	
	def opacity
		percent = 0.2
		0xFF * percent
	end
	
	def scale
		#~ Calculate the amount by which to scale the shadow
		1
	end
end
