#!/usr/bin/ruby

require 'set'

require 'rubygems'
require 'gosu'
require 'chipmunk'
require './Chipmunk/Shape'
require './Chipmunk/Space3D'
require './Chipmunk/EternityMod'

require './GameObjects/Physics'
 
class Camera
	include PhysicalProperties
	
	attr_reader :shape, :queue

	def initialize(space, entity)
		@space = space
		@entity = entity
		
		@center = Struct.new(:x, :y).new
		@center.x = $window.width.to_meters / 2
		@center.y = $window.height.to_meters / 2
		
		mass = @entity.shape.body.m
		
		@shape = CP::Shape::Rect.new(CP::Body.new(mass, Float::INFINITY), :bottom_left, 
									$window.height.to_meters, $window.width.to_meters)
		
		@shape.sensor = true
		@shape.collision_type = :camera
		@shape.body.p = CP::Vec2.new(@entity.x - @center.x, @entity.y - @center.y)
		
		space.add_2D @shape
		
		@queue = Set.new
	end
	
	def update
		#~ @shape.body.reset_forces
		#~ self.move(@entity.shape.body.f)
		warp @entity.p
	end
	
	def move(force, offset=CP::ZERO_VEC_2)
		@shape.body.apply_force force, offset
	end
	
	def warp(vec2)
		self.p = vec2
		self.p.x -= @center.x
		self.p.y -= @center.y + @entity.z
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
