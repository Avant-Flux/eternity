#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.15.2010
require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'Chipmunk/ChipmunkInterfaceMod'
require 'Chipmunk/EternityMod'

require 'Drawing/Wireframe'

class Building
	attr_reader :space, :shape

	def initialize(window, space, hash={})
		#~ Set default values for hash values if they are not already set.
		hash[:dimensions] = [1,1,1] unless hash[:dimensions]
		hash[:position] = [0,0,0] unless hash[:position]
		hash[:offset] = CP::Vec2.new(0,0) unless hash[:offset]
		
		@window = window
		@space = space
		@shape = CP::Shape_3D::Rect.new(self, space, :building, hash[:position], 0, :bottom_left, 
							hash[:dimensions][0], hash[:dimensions][1], hash[:dimensions][2], 
							Float::INFINITY, Float::INFINITY, hash[:offset])
		@wireframe = Wireframe::Building.new(@window, @shape, :white)
		space.add self, :static
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
