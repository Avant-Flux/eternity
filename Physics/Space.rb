#!/usr/bin/ruby

require 'set'

module Physics
	class Space < CP::Space
		attr_reader :dt
		
		def initialize
			super()
			
			self.iterations = 10
			#~ self.damping = 0.2
			
			@t_previous = Gosu.milliseconds
			
			@g = -9.8
			
			@bodies = Set.new()
		end
		
		def add_body(body)
			super(body)
			
			@bodies.add body
			body.add_elevation initial_elevation body
		end
		
		def add_shape(shape)
			super(shape)
		end
		
		def step
			@dt = timestep()
			
			@bodies.each do |body|
				vertical_integration body, @dt
				apply_resistive_force body, @dt
			end
			
			super(@dt) # Timestep in seconds
			
			@bodies.each do |body|
				body.reset_forces
			end
		end
		
		private
		
		def timestep
			# TODO: Add means of calculating timestep dynamically
			# Assumption:	dt will only be called once.
			# 				If this method is called more than once,
			# 				there is no guarantee the results will
			# 				be consistent between calls.
			dt = Gosu.milliseconds - @t_previous
			
			# convert to seconds
			dt /= 1000.0
			
			@t_previous = Gosu.milliseconds
			
			return dt
		end
		
		def vertical_integration(body, dt)
			# Iteration for third dimension
			
			body.vz += body.az * dt
			body.pz += body.vz * dt
			
			if body.pz > body.elevation
				# TODO: Change conditional to be if in_air? to handle uneven terrain
				# Apply gravity
				body.vz += @g * dt
				body.pz += body.vz * dt
			end
			
			if body.pz < body.elevation
				body.pz = body.elevation
				body.vz = 0
				body.az = 0
				
				body.gameobject.resolve_ground_collision
			end
		end
		
		def apply_resistive_force(body, dt)
			# Apply a resistive force in the opposite direction of the velocity
			magnitude = body.v.length
			#~ puts "v: #{body.v.length}  f: #{body.f.length}"
			if magnitude > 0.04 # Only apply resistive forces if object is in motion
				#~ puts "moving"
				
				# Friction should be in the opposite direction of velocity
				# Parallel, but opposite sign
				direction_vector = body.v / magnitude
				
				# TODO: Implement the following block as a true function
				resistive_force = if body.gameobject.in_air?
					air_resistance body, direction_vector
				else
					friction body, direction_vector
				end
				
				body.apply_force resistive_force, CP::ZERO_VEC_2
			else
				# If velocity is below a certain threshold, set it to zero.
				# Used to combat inaccuracies with floats.
				
				
				body.v.x = 0
				body.v.y = 0
			end
		end
		
		def initial_elevation(body, layers=CP::ALL_LAYERS, group=CP::NO_GROUP)
			# Calculate initial elevation
			# Take the maximum of all possible elevations
			# 
			# This method is only used to set initial elevation.
			# Elevation for objects already in the space in handled by Physics::Space
			# Even so, the layers variable may need to be changed,
			# if there are some elements which should not be tested against.
			elevation = 0
			
			point_query body.local2world(CP::Vec2::ZERO), layers, group do |shape|
				if shape.gameobject.is_a? StaticObject
					env = shape.gameobject
					new_elevation = env.height + env.body.pz
					
					if new_elevation > elevation
						elevation = new_elevation
					end
				end
			end
			
			return elevation
		end
		
		private
		
		def air_resistance(body, movement_direction)
			return CP::ZERO_VEC_2
		end
		
		def friction(body, movement_direction)
			u = 1.7# Coefficient of friction
			# TODO: Calculate coefficient of friction by adding surface and entity components
			
			# Normal force
			# Currently assuming that all terrain is flat
			# TODO:	Update normal force to take account of terrain
			# 		Normal = mg*cos(theta)
			normal = body.m * @g
			
			printf #{body.v.to_world}
			
			movement_direction*u*normal*2 # g is negative, so the direction will be reversed
		end
	end
end
