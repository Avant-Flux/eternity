#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'
require 'chipmunk'
require './Chipmunk/Shape'
require './Chipmunk/Space_3D'
require './Chipmunk/EternityMod'
 
class Camera
	attr_reader :shape, :queue

	def initialize(space, entity)
		@space = space
		@entity = entity
		
		width = $window.width.to_meters
		depth = $window.height.to_meters
		
		mass = @entity.shape.body.m
		
		@shape = CP::Shape::Rect.new(CP::Body.new(mass, Float::INFINITY), :bottom_left, depth, width)
		
		@shape.sensor = true
		@shape.collision_type = :camera
		@shape.body.p = CP::Vec2.new(@entity.shape.x-width/2.0, @entity.shape.y-depth/2.0)
		
		space.add self
		shapes = space.shapes[:nonstatic].delete(@shape)
		
		@queue = Set.new
	end
	
	def update
		@shape.body.reset_forces
	end
	
	def move(force, offset=CP::ZERO_VEC_2)
		@shape.body.apply_force force, offset
	end
	
	def x
		@shape.body.p.x
	end
	
	def y
		@shape.body.p.y
	end
end

module CollisionHandler
	#~ Collision type for usage with the CP::Shape and CP::Body used for the camera
	#~ This is the collision handler for a sensor object
	class Camera
		#~ a has collision type :camera
		#~ b is the Chipmunk object for the Entity
		def begin(a, b, arbiter)
			$camera.queue.add b.entity
		end
				
		def separate(a, b, arbiter)
			$camera.queue.delete b.entity
		end
	end
end
