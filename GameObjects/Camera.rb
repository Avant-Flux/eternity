#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.20.2010
require 'set'

require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'Chipmunk/Shape'
require 'Chipmunk/EternityMod'
 
class Camera
	attr_reader :shape

	def initialize(space, width, depth, entity)
		mass = entity.shape.body.m
		@shape = CP::Shape::Rect.new(CP::Body.new(mass, Float::INFINITY), :top_left, width, depth)
		@entity = entity
		
		space.add self
		shapes = space.shapes[:nonstatic].delete(@shape)
		
		@queue = Set.new
	end
	
	def move(force, offset=CP::Vec2.new(0,0))
		@shape.body.apply_force force, offset
	end
end

module CollisionHandler
	#~ Collision type for usage with the CP::Shape and CP::Body used for the camera
	#~ This is the collision handler for a sensor object
	class Camera
		def initialize(camera) #Argument should be the actual camera
			@camera = camera
		end
		
		def begin(camera, b, arbiter)
			return true
		end
		
		def pre(camera, b, arbiter) #Determine whether to process collision or not
			@camera.queue.add b
		end
		
		def sep(camera, b, arbiter)	#Stuff to do after the shapes separate
			@camera.queue.delete b
		end
	end
end
