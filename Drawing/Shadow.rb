#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require './Drawing/GosuPatch'

class Shadow
	def initialize(radius)
		color = Gosu::Color::BLUE
		
		r2 = radius * 2
		
		@image = TexPlay.create_blank_image($window, r2+2, r2+2)
		@image.circle radius+1, radius+1, radius, :color => color, :fill => true
	end
	
	def update
		
	end
	
	def draw(x, y, z, elevation)
		@image.draw_centered x, y - elevation, z, 1,1, 0xffffffff
	end
end
