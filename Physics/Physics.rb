#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'
require "./Physics/PhysicsMixins"

class Numeric
	def to_px
		#~ Convert from meters to pixels
		(self*Physics::PhysicsObject.scale).round
	end
	
	def to_meters
		#~ Convert from pixels to meters
		self/(Physics::PhysicsObject.scale.to_f) #Insure that integer division is not used
	end
end

module Physics
	#This is the new structure for the chipmunk handling of the game engine
	#It should create a complete abstraction of the underlying chipmunk code.
	#It may eventually be possible to forgo usage of chipmunk-ffi at some point
	#and simply use ffi and the C library.
	
	class PhysicsObject
		include Physics::Positioning
	
		attr_reader :bottom, :side
		
		# Hold a reference to a CP::Space for the shapes and bodies to be added to
		@@space
		# Set the scale for conversion between meters and pixels
		@@scale = 44
		
		DIRECTION_UP = (3*Math::PI/2.0)
		DIRECTION_DOWN = (Math::PI/2.0)
		DIRECTION_LEFT = (Math::PI)
		DIRECTION_RIGHT = (2*Math::PI)
		
		LAYER_BOTTOM = 1
		LAYER_SIDE = 2
		
		def initialize(position, bottom, side)
			@bottom = bottom
			@side = side
			
			self.position = position
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
			@bottom.body.a = DIRECTION_UP
			@side.body.a = DIRECTION_UP
		end
		
		def init_layers
			@bottom.layers = LAYER_BOTTOM
			@side.layers = LAYER_SIDE
		end
	end
	
	class NonstaticObject < PhysicsObject
		include Physics::ForceApplication
		include Physics::Rotation
		include Physics::SpeedLimit
		include Physics::Elevation
	
		def initialize(pos, bottom, side)
			super(pos, bottom, side)
			
			#~ link_side_and_bottom
		end
		
		private
		
		def link_side_and_bottom
			# For this to work, the side must be unable to rotate, 
			# and the bottom free to rotate.
			
			# Use a groove joint to implement this link.
				# Connect the stable end of the joint to the side, and
				# the moving "pin" to the bottom.
				
				# Allow the groove to extend infinitely downwards so that
				# the movement of the object modeled is inhibited as little
				# as possible.
				
			CP::GrooveJoint.new	@side, @bottom, 
						CP::ZERO_VEC_2, CP::Vec2.new(0, Float::INFINITY),	#From a to b on @side
						CP::ZERO_VEC_2										#Anchor on @bottom
		end
	end
	
	class StaticObject < PhysicsObject
		def initialize(pos, bottom, side)
			super(pos, bottom, side)
		end
	end
	
	class Camera
		attr_reader :shape
	
		def initialize(camera_obj)
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
			#Use the supplied mass for the circle only, as the rectangle should not rotate.
			
			#Define the bottom of the Entity as a circle, and the side as a rectangle.
			#This approximates the volume as a cylinder.
			
			bottom = Shape::Circle.new	self, Body.new(self, mass,moment), dimentions[1], CP::ZERO_VEC_2
			side = Shape::Rect.new		self, Body.new(self, mass,Float::INFINITY), :bottom_left,
										dimentions[1], dimentions[2]
			
			super(pos, bottom, side)
			
			@entity = entity
			
			@bottom.collision_type = :entity
			@side.collision_type = :render_object
			
			@elevation = 0
			
			@bottom.body.a = DIRECTION_UP
			@side.body.a = DIRECTION_UP
		
			@bottom.layers = 1
			@side.layers = 4
			
			CP::GrooveJoint.new	@side, @bottom, 
						CP::ZERO_VEC_2, CP::Vec2.new(0, 1),	#From a to b on @side
						CP::ZERO_VEC_2										#Anchor on @bottom
		end
		
		def width
			@side.width
		end
		
		def depth
			@bottom.radius
		end
		
		def height
			@side.width
		end
	end
	
	class EnvironmentObject < StaticObject
		def initialize(env, pos=[0,0,0], dimentions=[1,1,1])
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
