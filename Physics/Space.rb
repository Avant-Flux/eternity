#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

module Physics
	class Space < CP::Space
		attr_reader :g, :dt, :air_damping
		alias :gravity :g
		
		# ===== DEBUG SYMBOLS
		#~ attr_reader :all
		# ===== END DEBUG SYMBOLS
		
		def initialize(dt, g = -9.8, damping=0.12, iterations=10)
			super()
			self.damping = damping
			self.iterations = iterations
			self.gravity = CP::Vec2::ZERO
			
			@dt = dt
			
			@nonstatic_objects = []
		end
		
		def step
			@nonstatic_objects.each do |gameobj|
				if gameobj.is_a? Entity # Necessary because Camera is included in this set
					gameobj.apply_force resistive_force(gameobj)
					
					#~ if (friction.to_angle - gameobj.v.to_angle - Math::PI).abs < 0.01
						#~ puts "fric"
						#~ gameobj.apply_force resistive_force(gameobj)
						#~ gameobj.apply_force CP::Vec2.new 1,0
						#~ gameobj.f += CP::Vec2.new 1,0
						#~ gameobj.vz += 10
						#~ 
					#~ else# gameobj.v.lengthsq > 0
						#~ gameobj.reset_forces
						#~ gameobj.v = CP::Vec2.new 0,0
					#~ end
				end
			end
			
			super @dt
			
			# Need to correct for passing through the floor on the same step
			
			@nonstatic_objects.each do |gameobj|
				if gameobj.is_a? Entity # Necessary because Camera is included in this set
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
						gameobj.resolve_ground_collision
						
						# Make sure to reset vz and fz
						gameobj.vz = 0.0
						gameobj.fz = 0.0
					end
				end
			end
		end
		
		def add(shape)
			# ===== DEBUG SYMBOLS
			#~ @all ||= Set.new
			#~ @all.add shape
			# ===== END DEBUG SYMBOLS
			
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
		
		def resistive_force(gameobj)
			#~ puts "friction #{resistive_force} #{gameobj.f} #{gameobj.f.normalize} #{gameobj.v.lengthsq}"
					
			#~ puts "#{gameobj.f} #{gameobj.v}"
			if gameobj.v == CP::ZERO_VEC_2
				# Resistive force can not be computed
				# Return a zero vector so this "force" can be applied without incident
				return CP::ZERO_VEC_2
			else
				if gameobj.pz > gameobj.elevation
					# Resistive force of air resistance
					#~ # Neg acceleration needed to reverse direction of friction
					#~ normal_force = -9.8 * gameobj.mass 
					#~ coefficient_of_friction = 0.01
					
					#~ gameobj.v.normalize * normal_force * coefficient_of_friction
					return CP::ZERO_VEC_2
				else
					# Force of friction
					# Neg acceleration needed to reverse direction of friction
					normal_force = -9.8 * gameobj.mass 
					coefficient_of_friction = 0.4
					
					return gameobj.v.normalize * normal_force * coefficient_of_friction
				end
			end
		end
	end
end
