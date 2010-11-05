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
		
	end
	
	def draw(x, y, z, elevation)
		@image.draw_centered x, y - elevation, z, 1,1, 0xff000000
	end
	
	private
	
	def color
		#~ Calculate the color of the shadow to be rendered, and mix in
		#~ The correct opacity
		
	end
	
	def opacity
		
	end
	
	def scale
		#~ Calculate the amount by which to scale the shadow
	end
end
