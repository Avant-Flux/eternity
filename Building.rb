#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.28.2010
require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'Chipmunk/ChipmunkInterfaceMod'
require 'Chipmunk/EternityMod'

class Building
	attr_reader :space, :shape

	def initialize(window, space, width, height, depth, pos, offset=CP::Vec2.new(0,0))
		@window = window
		@space = space
		@shape = CP::Shape_3D::Rect.new(self, space, :building, pos, :bottom_left, width, depth, height, 
							Float::INFINITY, Float::INFINITY, offset)
		space.add self
	end
	
	def draw
		#Bottom
		@window.draw_line(@shape.x, @shape.y, Gosu::Color::BLACK, 
						@shape.x + @shape.width, @shape.y, Gosu::Color::BLACK)
		#Right
		@window.draw_line(@shape.x + @shape.width, @shape.y, Gosu::Color::BLACK, 
						@shape.x + @shape.width, @shape.y, Gosu::Color::BLACK)
		#Top
		@window.draw_line(@shape.x, @shape.y, Gosu::Color::BLACK, 
						@shape.x + @shape.width, @shape.y, Gosu::Color::BLACK)
		#Left
		@window.draw_line(@shape.x, @shape.y, Gosu::Color::BLACK, 
						@shape.x + @shape.width, @shape.y, Gosu::Color::BLACK)
	end
	
	def update
		
	end
	
	def width
		@shape.width
	end
	
	def depth
		@shape.depth
	end
	
	def height
		@shape.height
	end
	
	def width= arg
		@shape.width = arg
	end
	
	def depth= arg
		@shape.depth = arg
	end
	
	def height= arg
		@shape.height = arg
	end
	
	private
	
	def draw_wireframe
		
	end
end
