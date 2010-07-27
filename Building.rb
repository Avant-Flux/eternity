#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.26.2010
require 'rubygems'
require 'chipmunk'
require 'Chipmunk/ChipmunkInterfaceMod'
require 'Chipmunk/EternityMod'

class Building
	attr_reader :space, :shape

	def initialize(space, width, height, depth, pos, offset=CP::Vec2.new(0,0))
		@space = space
		@shape = CP::Shape_3D.new(self, space, :building, pos, :bottom_left, width, depth, height, 
							Float::INFINITY, Float::INFINITY, offset)
		space.add self
	end
	
	def draw
		
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
end
