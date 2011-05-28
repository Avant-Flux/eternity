#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'
require "./Physics/PhysicsMixins"

class Numeric
	def to_px
		# Convert from meters to pixels
		(self*Physics::PhysicsObject.scale).round
	end
	
	def to_meters
		# Convert from pixels to meters
		self/(Physics::PhysicsObject.scale.to_f) #Insure that integer division is not used
	end
end

module Physics
	MAX_Z = 10000000

	#This is the new structure for the chipmunk handling of the game engine
	#It should create a complete abstraction of the underlying chipmunk code.
	#It may eventually be possible to forgo usage of chipmunk-ffi at some point
	#and simply use ffi and the C library.
	
	class PhysicsObject
		include Physics::Positioning
	
		attr_reader :shape, :height
		
		# Hold a reference to a CP::Space for the shapes and bodies to be added to
		@@space
		# Set the scale for conversion between meters and pixels
		@@scale = 44
		
		DIRECTION_UP = (3*Math::PI/2.0)
		DIRECTION_DOWN = (Math::PI/2.0)
		DIRECTION_LEFT = (Math::PI)
		DIRECTION_RIGHT = (2*Math::PI)
		
		def initialize(position, shape, height)
			@shape = shape
			
			@shape.body.p.x = position[0]
			@shape.body.p.y = position[1]
			@pz = position[2].to_f	#Force z to be a float just like x and y
			@vz = 0.to_f
			@az = 0.to_f
			@fz = 0.to_f
			
			@height = height;
			
			init_orientation
		end
		
		class << self
			def scale
				@@scale
			end
			
			def scale=(arg)
				@@scale = arg
			end
		end
		
		private
		
		# Set the initial angle of the bodies.  The bodies are initialized pointing
		# at 0 rad, aka right.  Thus, they need to be rotated before being used.
		def init_orientation
			@shape.body.a = DIRECTION_UP
		end
	end
	
	class NonstaticObject < PhysicsObject
		include Physics::ForceApplication
		include Physics::Rotation
		include Physics::SpeedLimit
		include Physics::Elevation
	
		def initialize(pos, shape, height)
			super(pos, shape, height)
		end
	end
	
	class StaticObject < PhysicsObject
		def initialize(pos, shape, height)
			super(pos, shape, height)
		end
	end
	
	class Camera
		attr_reader :shape
	
		def initialize(camera_obj)
			# Add the height of the tallest known entity to the bottom(down the screen) of the 
			# hitbox for the camera.
		
			@center = Struct.new(:x, :y).new
			@center.x = $window.width.to_meters / 2
			@center.y = $window.height.to_meters / 2
			
			mass = @entity.shape.body.m
			
			@shape = Shape::Rect.new(camera_obj, CP::Body.new(mass, Float::INFINITY), :bottom_left, 
										$window.height.to_meters, $window.width.to_meters)
			
			@shape.sensor = true
			@shape.collision_type = :camera
			@shape.body.p = CP::Vec2.new(@entity.x - @center.x, @entity.y - @center.y)
			@shape.body.a = (3*Math::PI/2.0)
		end
		
		def px
			
		end
		
		def py
			
		end
		
		def pz
			
		end
	end
	
	class Entity < NonstaticObject
		attr_reader :entity
	
		def initialize(entity, mass, moment, pos=[0,0,0], dimentions=[1,1,1])
			# Represent only the shape of the bottom, and the height of the object.  Thus, all
			# all objects are represented by some sort of prism.
			
			shape = Shape::Circle.new self, Body.new(self, mass,moment), dimentions[1], CP::ZERO_VEC_2
			
			super(pos, shape, dimentions[2])
			
			@entity = entity
			
			@shape.collision_type = :entity
			
			@elevation = 0
		end
		
		def width
			@shape.radius * 2
		end
		
		def depth
			@shape.radius
		end
	end
	
	class EnvironmentObject < StaticObject
		attr_reader :environment
	
		def initialize(environment, pos=[0,0,0], dimentions=[1,1,1])
			@environment = environment
		
			bottom =	Shape::Rect.new	self, CP::Body.new(Float::INFINITY,Float::INFINITY), 
										:bottom_left, dimentions[0], dimentions[1]
			
			side = 		Shape::Rect.new	self, CP::Body.new(Float::INFINITY,Float::INFINITY), 
										:bottom_left, dimentions[0], dimentions[1] + dimentions[2]
			
			super(pos, bottom, side)
			
			@bottom.collision_type = :environment
			@side.collision_type = :render_object
			
			@height = dimentions[2]
		end
		
		def width
			@bottom.width
		end
		
		def depth
			@bottom.height
		end
		
		def height
			@height
		end
	end
end
