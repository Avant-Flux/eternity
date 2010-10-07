#!/usr/bin/ruby
#~ Name: Jason
require 'set'

require 'rubygems'
require 'gosu'
require 'chipmunk'
require 'Chipmunk/Shape'
require 'Chipmunk/Space_3D'
require 'Chipmunk/EternityMod'
 
class Camera
	attr_reader :shape, :queue

	def initialize(space, width, depth, entity)
		@entity = entity
		@space = space
		
		mass = @entity.shape.body.m
		@shape = CP::Shape::Rect.new(CP::Body.new(mass, Float::INFINITY), :top_left, width, depth)
		
		@shape.collision_type = :camera
		@shape.body.a = (3*Math::PI/2.0)
		@shape.body.p = CP::Vec2.new(@entity.shape.x-width/2.0, @entity.shape.y-depth/2.0)
		
		#~ @shape = CP::Shape_3D::Rect.new(self, space, :camera, [@entity.shape.x-width/2.0, @entity.shape.y-depth/2.0, 0], 0, :top_left, width, depth, 1, mass, Float::INFINITY)
		
		@shape.sensor = true
		@width = width
		@depth = depth
		
		space.add_shape @shape
		space.add_body @shape.body
		#~ space.add self
		#~ shapes = space.shapes[:nonstatic].delete(@shape)
		
		@queue = Array.new
	end
	
	def update
		@shape.body.reset_forces
		#~ @queue = @space.active_shapes_hash.query_by_bb BB.new(0,0,@width,@height)
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
		def initialize(camera) #Argument should be the actual camera
			@camera = camera
		end
		
		def begin(a, b, arbiter)
			puts "hey"
			#~ return true
		end
		
		def pre_solve(a, b, arbiter) #Determine whether to process collision or not
			puts "on"
			#~ @camera.queue.add b
		end
		
		def post_solve(a, b, arbiter)
			puts "yo"
			#~ @camera.queue.add b
		end
		
		def separate(a, b, arbiter)	#Stuff to do after the shapes separate
			puts "off"
			#~ @camera.queue.delete b
		end
	end
end
