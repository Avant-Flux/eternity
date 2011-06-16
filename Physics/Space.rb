#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

module Physics
	class Space < CP::Space
		attr_reader :g, :air_damping
		alias :gravity :g
		
		def initialize(dt, g = -9.8, surface_damping=0.12, iterations=10)
			super()
			self.damping = surface_damping
			self.iterations = iterations
			self.gravity = CP::ZERO_VEC_2
			
			@dt = dt
			
			@nonstatic_objects = []
		end
		
		def step
			super @dt
			
			@nonstatic_objects.each do |obj|
				obj.vz = obj.fz * obj.mass * @dt
				obj.pz += obj.vz * @dt
			end
		end
		
		def add(entity)
			#Add shape to space.  This depends on whether or not the shape is static.
			if entity.static?
				# Add shape to space
				add_static_shape entity.shape
			else
				# Add shape to space
				add_shape entity.shape
				add_body entity.shape.body
				@nonstatic_objects << entity
			end
			
			add_body entity.shape.body
		end
		
		def remove(entity)
			#Remove shape from space.  This depends on whether or not the shape is static.
			if entity.static?
				#Object is static
				remove_static_shape entity.shape
			else
				#Object is nonstatic
				remove_shape entity.shape
				@nonstatic_objects.delete entity
			end
			
			remove_body entity.shape.body
		end
		
		def find
			
		end
	end
end
