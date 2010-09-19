#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.18.2010
require 'set'

require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'Chipmunk/Shape'
require 'Chipmunk/EternityMod'
 
class Camera
	def initialize(width, depth, entity)
		mass = entity.shape.body.m
		@shape = CP::Shape::Rect.new(CP::Body.new(mass, Float::INFINITY), :top_left, width, depth)
		@entity = entity
		
		@queue = Set.new
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
