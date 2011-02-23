#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'

module Physics
	class Space < CP::Space
		#Create custom velocity and position functions for objects which respond to gravity. 
		GRAVITY_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			body.update_velocity($space.g, $space.air_damping, dt)
			physics_obj = body.physics_obj
			
			#If the player hits the ground			
			if physics_obj.pz < physics_obj.elevation
				#Reset z-coordinate to be the same as the elevation
				physics_obj.pz = physics_obj.elevation
				#When setting position, always set velocity as well.
				physics_obj.vz = 0
				
				#Do things that need to be done when hitting the ground.
				physics_obj.entity.resolve_ground_collision
				physics_obj.entity.resolve_fall_damage body.v.y
			end
		end
		
		# Apply this function to the bottom object to get the side to move to compensate
		# and thus prevent wild fluctuations in z
		COMPENSATION_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			body.update_velocity(CP::ZERO_VEC_2, dmp, dt)
			
			#BUG does not allow jumping up-left.
			if body.rot.y != 0
				body.physics_obj.side.body.p.y += body.v.y*dt
			end
		end
		
		attr_reader :g, :air_damping
		
		def initialize(dt, g = -9.8, surface_damping=0.12, air_damping=1, iterations=10)
			super()
			self.damping = surface_damping
			self.iterations = iterations
			self.gravity = CP::ZERO_VEC_2
			
			@dt = dt
			@g = CP::Vec2.new(0, g)
			@air_damping = air_damping
			
			#~ @shapes = {:static = [], :nonstatic = []}
		end
		
		def step
			super @dt
		end
		
		def add(physics_obj)
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? NonstaticObject
				# Add gravity function to body
				physics_obj.side.body.velocity_func = GRAVITY_VELOCITY_FUNC
				
				# Add compensation function (pseudo constraint)
				physics_obj.bottom.body.velocity_func = COMPENSATION_VELOCITY_FUNC
				
				# Add shapes to space
				add_shape physics_obj.bottom
				add_shape physics_obj.side
			else
				# Add shapes to space
				add_static_shape physics_obj.bottom
				add_static_shape physics_obj.side
			end
		end
		
		def remove(physics_obj)
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? NonstaticObject
				#Object is nonstatic
				remove_shape physics_obj.bottom
				remove_shape physics_obj.side
			else
				#Object is static
				
				remove_static_shape physics_obj.bottom
				remove_static_shape physics_obj.side
			end
		end
		
		def add_shape(shape)
			super shape
			add_body shape.body
		end
		
		def remove_shape(shape)
			super shape
			remove_body shape.body
		end
		
		def add_static_shape(shape)
			super shape
			add_body shape.body
		end
		
		def remove_static_shape(shape)
			super shape
			remove_body shape.body
		end
		
		def find
			
		end
	end
end
