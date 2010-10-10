#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'Chipmunk/Shape'
require 'Chipmunk/Space_3D'
require 'Chipmunk/EternityMod'
 
class Camera
	attr_reader :shape, :queue

	def initialize(space, entity)
		@space = space
		@entity = entity
		
		@width = $window.width.to_meters
		@depth = $window.height.to_meters
		
		mass = @entity.shape.body.m
		#~ @shape = CP::Shape_3D::Rect.new(self, space, :camera, [@entity.shape.x-@width/2.0, @entity.shape.y-@depth/2.0, 0], 0, :top_left, 20, 20, 1, mass, Float::INFINITY)
		#~ @shape = CP::Shape::Rect.new(CP::Body.new(mass, Float::INFINITY), :top_left, @width, @depth)
		@shape = CP::Shape::Circle.new(CP::Body.new(mass, Float::INFINITY), @width, CP::Vec2.new(0,0))
		
		@shape.sensor = true
		@shape.collision_type = :camera
		@shape.body.a = (3*Math::PI/2.0)
		@shape.body.p = CP::Vec2.new(@entity.shape.x-@width/2.0, @entity.shape.y-@depth/2.0)
		
		space.add self
		shapes = space.shapes[:nonstatic].delete(@shape)
		
		@queue = Set.new
	end
	
	def update
		@shape.body.reset_forces
		#~ p @queue
	end
	
	def move(force, offset=CP::Vec2.new(0,0))
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
		def begin(a, b, arbiter)
			$camera.queue.add b.entity
		end
				
		def separate(a, b, arbiter)	#Stuff to do after the shapes separate
			$camera.queue.delete b.entity
		end
	end
end
