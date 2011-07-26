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
			
			@nonstatic_objects.each do |gameobj|
				if gameobj.is_a? Entity
					if gameobj.pz > gameobj.elevation
						# Apply gravity
						az = -9.8
						gameobj.vz += az * @dt
						gameobj.pz += gameobj.vz * @dt
					elsif gameobj.pz < gameobj.elevation
						# Reset to elevation (pz)
						gameobj.pz = gameobj.elevation
						# Apply fall damage and other calculations
						# Make sure to reset vz and fz
						gameobj.vz = 0
						gameobj.fz = 0
						
						gameobj.resolve_ground_collision
					else # Exactly equal
						# As doubles are being dealt with, this will only happen reliably
						# when pz is set manually.
						
					end
					
					
					
					# Newtonian physics integration for the z dimension
					az = gameobj.fz / gameobj.mass
					gameobj.vz += az * @dt
					# TODO implement terminal velocity
					terminal_velocity = -94
					if gameobj.vz < terminal_velocity
						gameobj.vz = terminal_velocity
					end
					gameobj.pz += gameobj.vz * @dt
				end
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
				@nonstatic_objects << shape.gameobj
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
