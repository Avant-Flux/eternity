#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'
require './Physics/SpaceVelocityFunctions'

module Physics
	class Space < CP::Space
		include Physics::SpaceVelocityFunctions
		include Physics::SpacePositionFunctions
		
		attr_reader :g, :air_damping
		alias :gravity :g
		
		def initialize(dt, g = -9.8, surface_damping=0.12, iterations=10)
			super()
			self.damping = surface_damping
			self.iterations = iterations
			self.gravity = CP::ZERO_VEC_2
			
			@dt = dt
			@g = g
			
			#~ @shapes = {:static = [], :nonstatic = []}
		end
		
		def step
			super @dt
		end
		
		def add(physics_obj)
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? NonstaticObject
				# Add gravity function to body
				#~ physics_obj.side.body.velocity_func = GRAVITY_VELOCITY_FUNC
				
				#~ physics_obj.side.body.position_func = GRAVITY_POSITION_FUNC
				
				# Add shapes to space
				add_shape physics_obj.shape
			else
				# Add shapes to space
				add_static_shape physics_obj.shape
			end
		end
		
		def remove(physics_obj)
			#Remove shape from space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? NonstaticObject
				#Object is nonstatic
				remove_shape physics_obj.shape
			else
				#Object is static
				remove_static_shape physics_obj.shape
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
