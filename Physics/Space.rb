#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

module Physics
	class Space < CP::Space
		attr_reader :g, :dt, :air_damping
		alias :gravity :g
		
		def initialize(dt, g = -9.8, damping=0.12, iterations=10)
			super()
			self.damping = damping
			self.iterations = iterations
			self.gravity = CP::Vec2::ZERO
			
			@dt = dt
			
			@nonstatic_objects = []
		end
		
		def step
			super @dt
			
			# Need to correct for passing through the floor on the same step
			
			@nonstatic_objects.each do |gameobj|
				if gameobj.is_a? Entity
					if gameobj.pz > gameobj.elevation
						# Compute increase in velocity due to gravity
						az = -9.8
						gameobj.vz += az * @dt
					end
					
					# Apply other forces
					# Newtonian physics integration for the z dimension
					# calculate velocity and acceration only
					if gameobj.fz
						az = gameobj.fz / gameobj.mass
						gameobj.vz += az * @dt
					end
					
					# TODO implement terminal velocity
					#~ terminal_velocity = -94
					#~ if gameobj.vz < terminal_velocity
						#~ gameobj.vz = terminal_velocity
					#~ end
					
					# Update position
					gameobj.pz += gameobj.vz * @dt
					
					# Make sure object does not pass through surface
					if gameobj.pz < gameobj.elevation
						# Reset to elevation (pz)
						gameobj.pz = gameobj.elevation
						# Apply fall damage and other calculations
						# Make sure to reset vz and fz
						gameobj.vz = 0.0
						gameobj.fz = 0.0
						
						gameobj.resolve_ground_collision
					end
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
				@nonstatic_objects << shape.gameobj if shape.respond_to? :gameobj
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
				@nonstatic_objects.delete shape.gameobj if shape.respond_to? :gameobj
			end
			
			remove_body shape.body
		end
		
		def find
			
		end
	end
end
