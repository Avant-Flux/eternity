#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require './Drawing/GosuPatch'

class Shadow
	def initialize
		color = Gosu::Color::BLUE
	
		@image = TexPlay.create_blank_image($window, 80, 80)
		@image.circle 40, 40, 20, :color => color, :fill => true
	end
	
	def update
		
	end
	
	def draw(x, y, z, elevation)
		@image.draw_centered x, y - elevation, z, 1,1, 0xffffffff
	end
end
