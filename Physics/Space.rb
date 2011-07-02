#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

module Physics
	class Space < CP::Space
		attr_reader :g, :air_damping
		alias :gravity :g
		
		def initialize(dt, g = -9.8, damping=0.12, iterations=10)
			super()
			self.damping = damping
			self.iterations = iterations
			self.gravity = CP::ZERO_VEC_2
			
			@dt = dt
			
			@nonstatic_objects = []
		end
		
		def step
			super @dt
			
			@nonstatic_objects.each do |obj|
				#~ obj.vz = obj.fz * obj.mass * @dt
				#~ obj.pz += obj.vz * @dt
			end
		end
		
		def add(shape)
			#Add shape to space.  This depends on whether or not the shape is static.
			if shape.static?
				# Add shape to space
				add_static_shape shape
			else
				# Add shape to space
				add_shape shape
				add_body shape.body
				@nonstatic_objects << shape.entity
			end
			
			add_body shape.body
		end
		
		def delete(shape)
			#Remove shape from space.  This depends on whether or not the shape is static.
			if shape.static?
				#Object is static
				remove_static_shape shape
			else
				#Object is nonstatic
				remove_shape shape
				@nonstatic_objects.delete shape.entity
			end
			
			remove_body shape.body
		end
		
		def find
			
		end
	end
end
