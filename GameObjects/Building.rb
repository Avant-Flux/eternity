#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'chipmunk'
require './Chipmunk/Space_3D'
require './Chipmunk/EternityMod'

require './Drawing/Wireframe'

class Building
	attr_reader :shape

	def initialize(space, options={})
		#~ Set default values for hash values if they are not already set.
		options[:dimensions] ||= [1,1,1]
		options[:position] ||= [0,0,0]
		options[:offset] ||= CP::Vec2.new(0,0)
		
		@shape = CP::Shape3D::Rect.new(self, :building, options[:position], 0, :bottom_left, 
							options[:dimensions][0], options[:dimensions][1], options[:dimensions][2], 
							Float::INFINITY, Float::INFINITY, options[:offset])
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
