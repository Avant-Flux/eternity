#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

# Create a chipmunk space to allow easy manipulation of interface elements.
# Use a class variable so that one
class InterfaceState < GameState
	def initialize(window, space, layers, name, player)
		super(window, space, layers, name)
	end
	
	def update
		super
	end
	
	def draw
		# Stat tracking box
		color = Gosu::Color::WHITE
		corner = [10,10]
		width = 300
		height = 100
		@window.draw_quad	corner[0],corner[1], color,
							corner[0]+width,corner[1], color,
							corner[0],corner[1]+height, color,
							corner[0]+width,corner[1]+height, color
	end
	
	def finalize
		super
	end
end
