#!/usr/bin/ruby

#~ Notes:
#~ Should contain one CP::Shape and a z coordinate, as well as other z related attributes 
require 'rubygems'
require 'chipmunk-ffi'
require './Chipmunk/Shape'

#Allows collision functions to be defined from within the shape
module CP	
	module Gravitation
		#Rules for applying gravity in the z-direction
		#	The z-axis is defined as positive in the upwards direction
		
		#Use this variable to determine if gravity's acceleration should be applied or not.
		#This way, gravitational acceleration is not applied multiple times during the
		#same fall.
		@apply_gravity = true
		
		def apply_gravity dt, g
			if @apply_gravity
				@az += g
				@apply_gravity = false
			end
		end
		
		def reset_gravity
			@apply_gravity = true
			
			old_vz = @vz
			old_az = @az
			@vz = 0
			@az = 0
			
			return old_vz, old_az
		end
		
		def iterate dt
			#~ puts "acc:#{@az}, vel:#{@vz}, pos:#{@z}"
			@vz += @az*dt
			@z += @vz*dt
		end
	end
	
	module Position #Have setters and getters for position and velocity
		attr_accessor :z, :az, :vz, :elevation
		@z = 0;		@az = 0;	 	@vz = 0
		
		def x
			self.body.p.x
		end
		
		def y
			self.body.p.y
		end
		
		def x= arg
			self.body.p.x = arg
		end
		
		def y= arg
			self.body.p.y = arg
		end
		
		#~ #Setters and getters for velocity
		#~ def v
			#~ #Compute the magnitude of the velocity in 3D space
			#~ #Use the cross product function in chipmunk
			#~ #CROSS_PRODUCT @xy.body.v, @xz.body.v
			#~ @xy.body.v.cross(@xz.body.v)
		#~ end
	end
	
	module Body3D
		#This is the new structure for the chipmunk handling of the game engine
		#It should create a complete abstraction of the underlying chipmunk code.
		#It may eventually be possible to forgo usage of chipmunk-ffi at some point
		#and simply use ffi and the C library.
		class PhysicsObject
			attr_reader :bottom, :side
		
			def initialize(bottom, side)
				@bottom = bottom
				@side = side
			end
			
			def set_positon(pos=[0,0,0])
				@bottom.p.x = pos[0]
				@bottom.p.y = pos[1]
				@side.p.y = pos[2]
			end
		end
		
		class Entity < PhysicsObject
			def initialize(mass, moment, pos=[0,0,0], dimentions=[1,1,1])
				#Use the supplied mass for the circle only, as the rectangle should not rotate.
				
				#Define the bottom of the Entity as a circle, and the side as a rectangle.
				#This approximates the volume as a cylinder.
				
				bottom = CP::Shape::Circle.new CP::Body.new(mass,moment), dimentions[0], CP::ZERO_VEC_2
				side = CP::Shape::Rect.new	CP::Body.new(mass,Float::INFINITY), :bottom_left,
											dimentions[0], dimentions[2]
				
				super(bottom, side)
				set_positon pos
			end
		end
		
		class EnvironmentObject < PhysicsObject
			def initialize(pos=[0,0,0], dimentions=[1,1,1])
				bottom =	CP::Shape::Rect.new	CP::Body.new(mass,Float::INFINITY), :bottom_left,
												dimentions[0], dimentions[1]
				side =		CP::Shape::Rect.new	CP::Body.new(mass,Float::INFINITY), :bottom_left,
												dimentions[0], dimentions[3]
				
				super(bottom, side)
				set_positon pos
			end
		end
	end

	module Shape3D
		class Circle < CP::Shape::Circle
			include CP::Position
			include CP::Gravitation
			
			attr_reader :entity, :height
			
			def initialize(entity, collision, pos, elevation, radius, height,
			mass, moment, offset=CP::Vec2.new(0, 0))
				super CP::Body.new(mass, moment), radius, offset
				
				#~ CP.moment_for_circle mass, inner_r, outer_r, CP::Vec2
				
				@entity = entity
				@height = height
				@az = @vz = 0.0
				self.collision_type = collision
				
				self.body.a = (3*Math::PI/2.0)
				self.body.p = CP::Vec2.new(pos[0], pos[1])
				@z = pos[2].to_f
			end
		end
		
		class Rect < CP::Shape::Rect
			include CP::Position
			include CP::Gravitation
			
			attr_reader :entity
			attr_accessor :width, :depth, :height
			
			def initialize(entity, collision, pos, elevation, center, width, depth, height, 
			mass, moment, offset=CP::Vec2.new(0, 0))
				super CP::Body.new(mass, moment), center, width, depth, offset
				
				 #~ CP.moment_for_poly(90, verts, vec2(0,0)).should == 420.0
				
				@entity = entity
				@width = width
				@depth = depth
				@height = height
				@az = @vz = 0
				self.collision_type = collision
				
				self.body.a = (3*Math::PI/2.0)
				self.body.p = CP::Vec2.new(pos[0], pos[1])
				@z = pos[2]
			end
		end
	end
end
