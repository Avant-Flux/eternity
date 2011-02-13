#!/usr/bin/ruby

require "./Physics/PhysicsMixins"

class Numeric
	def to_px
		#~ Convert from meters to pixels
		self*Physics::PhysicsObject.scale
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
		attr_reader :bottom, :side
		
		# Set the scale for conversion between meters and pixels
		@@scale = 44
		
		DIRECTION_UP = (3*Math::PI/2.0)
		DIRECTION_DOWN = (Math::PI/2.0)
		DIRECTION_LEFT = (Math::PI)
		DIRECTION_RIGHT = (2*Math::PI)
		
		include Physics::Dimension
		include Physics::Positioning
	
		def initialize(position, bottom, side)
			@bottom = bottom
			@side = side
				
			self.position = position
			init_orientation
			#~ init_gravity
		end
		
		class << self
			def scale
				@@scale
			end
			
			def scale= arg
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
	end
	
	class NonstaticObject < PhysicsObject
		include Physics::ForceApplication
	
		def initialize(pos, bottom, side)
			super(pos, bottom, side)
			
			link_side_and_bottom
		end
		
		private
		
		def link_side_and_bottom
			# For this to work, the side must be unable to rotate, 
			# and the bottom free to rotate.
			
			# Use a slide joint to implement this link.
				# Connect the stable end of the joint to the side, and
				# the moving "pin" to the bottom.
				
				# Allow the groove to extend infinitely downwards so that
				# the movement of the object modeled is inhibited as little
				# as possible.
		end
	end
	
	class StaticObject < PhysicsObject
		attr_reader :render_object
	
		def initialize(pos, bottom, side, render_object)
			super(pos, bottom, side)
			
			@render_object = render_object
			@render_object.body.a = DIRECTION_UP
		end
	end
	
	class Entity < NonstaticObject
		def initialize(entity, mass, moment, pos=[0,0,0], dimentions=[1,1,1])
			#Use the supplied mass for the circle only, as the rectangle should not rotate.
			
			#Define the bottom of the Entity as a circle, and the side as a rectangle.
			#This approximates the volume as a cylinder.
			
			bottom = Shape::Circle.new	entity, CP::Body.new(mass,moment), dimentions[0], CP::ZERO_VEC_2
			side = Shape::Rect.new		entity, CP::Body.new(mass,Float::INFINITY), :bottom_left,
										dimentions[1], dimentions[2]
			
			super(pos, bottom, side)
			
			@bottom.collision_type = :entity
			@side.collision_type = :render_object
		end
	end
	
	class EnvironmentObject < StaticObject
		def initialize(env, pos=[0,0,0], dimentions=[1,1,1])
			bottom =	Shape::Rect.new	env, CP::Body.new(Float::INFINITY,Float::INFINITY), 
										:bottom_left, dimentions[0], dimentions[1]
			side =		Shape::Rect.new	env, CP::Body.new(Float::INFINITY,Float::INFINITY), 
										:bottom_left, dimentions[0], dimentions[3]
			
			render_object = Shape::Rect.new	env, CP::Body.new(Float::INFINITY,Float::INFINITY), 
											:bottom_left, side.width, side.height + bottom.height
			
			super(pos, bottom, side, render_object)
			
			@bottom.collision_type = :environment
			@side.collision_type = :environment_side
			@render_object.collision_type = :render_object
		end
	end
end
