#!/usr/bin/ruby

#~ Notes:
#~ Should contain one CP::Shape and a z coordinate, as well as other z related attributes 
require 'rubygems'
require 'chipmunk'
require 'Chipmunk/Shape'

#Allows collision functions to be defined from within the shape
module CP	
	module Gravitation
		#Rules for applying gravity in the z-direction
		#	The z-axis is defined as positive in the upwards direction
		def apply_gravity dt
			@az = @space.g
			
			#~ if @z <= 0.00000001
				#~ @z = 500
			#~ end
		end
		
		def reset_gravity
			old_az = @az
			old_vz = @vz
			@az = 0
			@vz = 0
			@z = @elevation
			return old_az, old_vz
		end
		
		def iterate dt
			#~ puts "acc:#{@az}, vel:#{@vz}, pos:#{@z}"
			@vz += @az*dt
			@z += @vz*dt
		end
	end
	
	module Position #Have setters and getters for position and velocity
		attr_accessor :az, :vz
		@az = 0
		@vz = 0
		
		def x
			self.body.p.x
		end
		
		def y
			self.body.p.y
		end
		
		def z
			@z
		end
		
		def x= arg
			self.body.p.x = arg
		end
		
		def y= arg
			self.body.p.y = arg
		end
		
		def z= arg
			@z = arg
		end
		
		#~ #Setters and getters for velocity
		#~ def v
			#~ #Compute the magnitude of the velocity in 3D space
			#~ #Use the cross product function in chipmunk
			#~ #CROSS_PRODUCT @xy.body.v, @xz.body.v
			#~ @xy.body.v.cross(@xz.body.v)
		#~ end
	end

	module Shape_3D
		class Circle < CP::Shape::Circle
			include CP::Position
			include CP::Gravitation
			
			attr_accessor :elevation
			attr_reader :space, :height, :entity
			
			def initialize(entity, space, collision, pos, elevation, radius, height,
			mass, moment, offset=CP::Vec2.new(0, 0))
				super CP::Body.new(mass, moment), radius, offset
				
				#~ CP.moment_for_circle mass, inner_r, outer_r, CP::Vec2
				
				@entity = entity
				@space = space
				@height = height
				@elevation = elevation
				@az = @vz = 0
				self.collision_type = collision
				
				self.body.a = (3*Math::PI/2.0)
				self.body.p = CP::Vec2.new(pos[0], pos[1])
				@z = pos[2]
			end
		end
		
		class Rect < CP::Shape::Rect
			include CP::Position
			include CP::Gravitation
			
			attr_reader :entity
			attr_accessor :width, :depth, :height, :elevation
			
			def initialize(entity, space, collision, pos, elevation, center, width, depth, height, 
			mass, moment, offset=CP::Vec2.new(0, 0))
				super CP::Body.new(mass, moment), center, width, depth, offset
				
				 #~ CP.moment_for_poly(90, verts, vec2(0,0)).should == 420.0
				
				@entity = entity
				@space = space
				@width = width
				@depth = depth
				@height = height
				@elevation = elevation
				@az = @vz = 0
				self.collision_type = collision
				
				self.body.a = (3*Math::PI/2.0)
				self.body.p = CP::Vec2.new(pos[0], pos[1])
				@z = pos[2]
			end
		end
	end
end

#~ space = CP::Space.new
#~ 
#~ CP::Shape_3D::Circle.new(space, :collide, [0,0,0], 200, 120, 20, 50)
#~ CP::Shape_3D::Rect.new(space, :collide, [0,0,0], :bottom, 100, 100, 500, 500, 20)
