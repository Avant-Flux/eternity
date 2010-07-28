#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.28.2010
require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'Chipmunk/ChipmunkInterfaceMod'
require 'Chipmunk/EternityMod'

require 'Wireframe'

class Building
	attr_reader :space, :shape

	def initialize(window, space, width, height, depth, pos, offset=CP::Vec2.new(0,0))
		@window = window
		@space = space
		@shape = CP::Shape_3D::Rect.new(self, space, :building, pos, 0, 
							:bottom_left, width, depth, height, 
							Float::INFINITY, Float::INFINITY, offset)
		@wireframe = Wireframe::Rect.new(@window, @shape)
		space.add self
	end
	
	def update
		@wireframe.update
	end
	
	def draw
		@wireframe.draw
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
