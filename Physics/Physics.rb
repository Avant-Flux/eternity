#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'
require "./Physics/PhysicsMixins"

class Numeric
	def to_px
		# Convert from meters to pixels
		(self*Physics.scale).round
	end
	
	def to_meters
		# Convert from pixels to meters
		self/(Physics.scale.to_f) #Insure that integer division is not used
	end
	
	#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
	def radians_to_vec2
		CP::Vec2.new(Math::cos(self), Math::sin(self))
	end
end

module Physics
	MAX_Z = 10000000

	# Set the scale for conversion between meters and pixels
	@@scale = 44
	class << self
		def scale
			@@scale
		end
		
		def scale=(arg)
			@@scale = arg
		end
	end
	
	module Direction
		UP = (3*Math::PI/2.0)
		DOWN = (Math::PI/2.0)
		LEFT = (Math::PI)
		RIGHT = (2*Math::PI)
		
		UP_VEC = CP::Vec2.for_angle UP
		DOWN_VEC = CP::Vec2.for_angle DOWN
		LEFT_VEC = CP::Vec2.for_angle LEFT
		RIGHT_VEC = CP::Vec2.for_angle RIGHT
		
		#~ N =
		#~ S =
		#~ E =
		#~ W =
		#~ NE =
		#~ NW =
		#~ SE =
		#~ SW =
	end
	
	#This is the new structure for the chipmunk handling of the game engine
	#It should create a complete abstraction of the underlying chipmunk code.
	#It may eventually be possible to forgo usage of chipmunk-ffi at some point
	#and simply use ffi and the C library.
	
	module TwoD_Support
		attr_reader :shape
	
		def init_physics(shape, position, args={})
			# Optional parameter geometry allows for specifying vertices manually 
			# with shape type polygon
			
			# Hash parameters
			# 	radius, width, depth, height, side, mass, moment, 
			# 	geometry, offset, collision_type, sensor
			
			# Set the default value of the offset to the zero vector
			unless args[:offset]
				args[:offset] = CP::ZERO_VEC_2
			end
			# Set depth to be the same value as height if no value of depth is given.
			# This means that a 2D physics initialization is being performed.
			unless args[:depth]
				args[:depth] = args[:height]
			end
			
			# Allow setting of static mass or moment
			if args[:mass] == :static
				args[:mass] = Float::INFINITY
			end
			if args[:moment] == :static
				args[:moment] = Float::INFINITY
			end
			
			body = Physics::Body.new self, args[:mass], args[:moment]
			
			@shape = case shape
				when :circle
					Physics::Shape::Circle.new	self, body, args[:radius], args[:offset]
				when :rectangle
					Physics::Shape::Rect.new	self, body, :bottom_left, 
												args[:width], args[:depth], args[:offset]
				when :square
					Physics::Shape::Rect.new	self, body, :bottom_left, 
												args[:side], args[:side], args[:offset]
				when :polygon
					Physics::Shape::Poly.new	self, body, args[:geometry], args[:offset]
			end
			
			@shape.body.p.x = position[0]
			@shape.body.p.y = position[1]
			
			# Set initial orientation
			@shape.body.a = Physics::Direction::UP
			
			# Set collision type
			@shape.collision_type = args[:collision_type]
		end
		
		def width
			# Assume that if the shape does not respond to the width method,
			# then it is a circle.
		
			if @shape.respond_to? :width
				return @shape.width
			else
				return @shape.radius * 2
			end
		end
		
		def height
			# Assume that if the shape does not respond to the height method,
			# then it is a circle.
		
			if @shape.respond_to? :width
				return @shape.width
			else
				return @shape.radius * 2
			end
		end
		
		def static?
			
		end
	end
	
	module ThreeD_Support
		# Include the methods from 2D, and change their names as necessary
		include TwoD_Support
		alias :init_2D_physics :init_physics
		alias :depth :height
		
		attr_accessor :pz, :vz, :fz, :height, :in_air
		
		def init_physics(shape, position, args={})
			init_2D_physics shape, position, args
			
			# Create values needed to track the z coordinate
			@pz = position[2].to_f	#Force z to be a float just like x and y
			@vz = 0.to_f
			@fz = 0.to_f
			
			@height = args[:height];
			
			@in_air = false;
		end
	end
	
	#~ class Entity < NonstaticObject
		#~ attr_reader :entity
	#~ 
		#~ def initialize(entity, mass, moment, pos=[0,0,0], dimentions=[1,1,1])
			#~ # Represent only the shape of the bottom, and the height of the object.  Thus, all
			#~ # all objects are represented by some sort of prism.
			#~ 
			#~ shape = Shape::Circle.new self, Body.new(self, mass,moment), dimentions[1], CP::ZERO_VEC_2
			#~ 
			#~ super(pos, shape, dimentions[2])
			#~ 
			#~ @entity = entity
			#~ 
			#~ @shape.collision_type = :entity
			#~ 
			#~ @elevation = 0
		#~ end
		#~ 
		#~ def width
			#~ @shape.radius * 2
		#~ end
		#~ 
		#~ def depth
			#~ @shape.radius
		#~ end
	#~ end
	#~ 
	#~ class EnvironmentObject < StaticObject
		#~ attr_reader :environment
	#~ 
		#~ def initialize(environment, pos=[0,0,0], dimentions=[1,1,1])
			#~ @environment = environment
		#~ 
			#~ bottom =	Shape::Rect.new	self, CP::Body.new(Float::INFINITY,Float::INFINITY), 
										#~ :bottom_left, dimentions[0], dimentions[1]
			#~ 
			#~ 
			#~ super(pos, shape, dimentions[2])
			#~ 
			#~ @shape.collision_type = :environment
			#~ 
			#~ @height = dimentions[2]
		#~ end
		#~ 
		#~ def width
			#~ @shape.width
		#~ end
		#~ 
		#~ def depth
			#~ @shape.height
		#~ end
	#~ end
end
