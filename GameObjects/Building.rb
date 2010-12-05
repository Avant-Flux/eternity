#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'chipmunk'
require './Chipmunk/Space_3D'
require './Chipmunk/EternityMod'

require './Drawing/Wireframe'

class Building
	attr_reader :space, :shape

	def initialize(space, hash={})
		#~ Set default values for hash values if they are not already set.
		hash[:dimensions] ||= [1,1,1]
		hash[:position] ||= [0,0,0]
		hash[:offset] ||= CP::Vec2.new(0,0)
		
		@space = space
		@shape = CP::Shape_3D::Rect.new(self, :building, hash[:position], 0, :bottom_left, 
							hash[:dimensions][0], hash[:dimensions][1], hash[:dimensions][2], 
							Float::INFINITY, Float::INFINITY, hash[:offset])
		@wireframe = Wireframe::Building.new(@shape, :white)
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
end
