#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'
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
	
	# Convert from degrees to radians
	def to_rad
		self * Math::PI / 180
	end
	
	# Convert from radians to degrees
	def to_deg
		self / Math::PI * 180
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
		X_HAT = CP::Vec2.new 1, 0
		Y_HAT = CP::Vec2.new(1, -1*Math.tan(70.to_rad)).normalize
		Z_HAT = CP::Vec2.new 0, -1
		
		UP = (3*Math::PI/2.0)
		DOWN = (Math::PI/2.0)
		LEFT = (Math::PI)
		RIGHT = (2*Math::PI)
		
		#~ UP_VEC = CP::Vec2.for_angle UP
		#~ DOWN_VEC = CP::Vec2.for_angle DOWN
		#~ LEFT_VEC = CP::Vec2.for_angle LEFT
		#~ RIGHT_VEC = CP::Vec2.for_angle RIGHT
		
		
		N = Y_HAT
		S = -Y_HAT
		E = X_HAT
		W = -X_HAT
		NE = (N + E).normalize
		NW = (N + W).normalize
		SE = (S + E).normalize
		SW = (S + W).normalize
	end

	#This is the new structure for the chipmunk handling of the game engine
	#It should create a complete abstraction of the underlying chipmunk code.

	module TwoD_Support
		include Physics::Dimentions::TwoD
	
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
					Physics::Shape::Rect.new	self, body, args[:width], args[:depth], args[:offset]
				when :square
					Physics::Shape::Rect.new	self, body, args[:side], args[:side], args[:offset]
				when :perspective_rectangle
					x_vec = Physics::Direction::X_HAT * args[:width]/2.0
					y_vec = Physics::Direction::Y_HAT * args[:depth]/2.0
					
					# Start in bottom-right and proceed CCW
					vertices = [(x_vec + y_vec),
								(x_vec + -y_vec),
								(-x_vec + -y_vec),
								(-x_vec + y_vec)]
					
					Physics::Shape::Poly.new	self, body, vertices
				when :polygon
					Physics::Shape::Poly.new	self, body, args[:geometry], args[:offset]
			end
			
			# Set up proper methods for accessing dimensions
			
			@shape.body.p.x = position[0]
			@shape.body.p.y = position[1]
			
			# Set initial orientation
			@shape.body.a = Physics::Direction::UP
			
			# Set collision type
			@shape.collision_type = args[:collision_type]
		end
	end
	
	module ThreeD_Support
		# Include the methods from 2D, and change their names as necessary
		include TwoD_Support
		include Physics::Dimentions::ThreeD
		
		alias :init_2D_physics :init_physics
		
		attr_accessor :pz, :vz, :fz, :height, :in_air
		
		def init_physics(shape, position, args={})
			shape = case shape #Convert into the corresponding 2D shape
						when :box
							:perspective_rectangle
						when :prism
							:polygon
						when :cylinder
							:circle
						else
							shape
					end
			
			init_2D_physics shape, position, args
			
			# Create values needed to track the z coordinate
			@pz = position[2].to_f	#Force z to be a float just like x and y
			@vz = 0.to_f
			@fz = 0.to_f
			
			@height = args[:height];
			
			@in_air = false;
		end
		
		module Box
			def init_physics(position, dimentions)
				# position		: x,y,z
				# dimentions	: width,depth,height
					# Height can either be Numeric or Proc
				
				# Generates a pseudo-3D box using the game's isometric projection
				# As this is only used for 3D objects, do not perform the CCW rotation
			end
		end
		
		module Prism
			def init_physics
				# Based on Polygon
			end
		end
		
		module Cylinder
			def init_physics
				# Based on Circle
			end
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
