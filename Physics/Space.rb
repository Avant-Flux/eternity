#!/usr/bin/ruby

require 'set'

module Physics
	class Space < CP::Space
		
		def initialize
			super()
			
			@t_accumulator = 0.0
			@dt = 1.0/60/4
			
			self.iterations = 10
			# self.damping = 1.0
						
			@g = -9.8
			
			@bodies = Set.new()
		end
		
		def add_body(body)
			super(body)
			
			@bodies.add body
			# set_initial_elevation body
		end
		
		def add_shape(shape)
			super(shape)
		end
		
		def update(dt)
			@t_accumulator += dt
			
			# Step multiple times
			# update objects
			# Calculate partial step
			# update objects
			# All objects should interpolate between those two states based on
			# alpha = accumulator / dt
			# OR
			# increase number of physics ticks per game tick, as an alternative method of
			# eliminating temporal aliasing
			# 	Increasing resolution makes aliasing less of a big deal
			
			# Need to limit max number of physics ticks that can happen per
			# game tick to eliminate the "spiral of death"
			
			# Add forces
			@bodies.each do |body|
				apply_resistive_force body
			end
			
			# Integration
			while @t_accumulator >= @dt do
				# puts "step"
				@bodies.each do |body|
					vertical_integration body, @dt
				end
				
				step(@dt) # Timestep in seconds
				
				@t_accumulator -= @dt
			end
			# puts @t_accumulator
			
			# Reset forces for next game tick
			@bodies.each do |body|
				body.reset_forces
			end
		end
		
		private
		
		def vertical_integration(body, dt)
			# Iteration for third dimension
			
			body.vz += body.az * dt
			body.pz += body.vz * dt
			
			# TODO: See if this double if structure really prevents flicker on ground collision
			if body.in_air?
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
		
		def apply_resistive_force(body)
			# Apply a resistive force in the opposite direction of the velocity
			magnitude = body.v.length
			#~ puts "v: #{body.v.length}  f: #{body.f.length}"
			if magnitude > 0.04 # Only apply resistive forces if object is in motion
				#~ puts "moving"
				
				# Friction should be in the opposite direction of velocity
				# Parallel, but opposite sign
				direction_vector = body.v / magnitude
				
				# TODO: Implement the following block as a true function
				resistive_force = if body.in_air?
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
		
		def set_initial_elevation(body, layers=CP::ALL_LAYERS, group=CP::NO_GROUP)
			# Calculate initial elevation
			# Take the maximum of all possible elevations
			# Also, set initial z position to match elevation.
			# 
			# This method is only used to set initial elevation.
			# Elevation for objects already in the space in handled by Physics::Space
			# Even so, the layers variable may need to be changed,
			# if there are some elements which should not be tested against.
			
			point_query body.p, layers, group do |shape|
				if shape.gameobject.is_a? StaticObject
					body.elevation_queue.add shape.gameobject
				end
			end
			
			body.pz = body.elevation
		end
		
		def air_resistance(body, movement_direction)
			return CP::ZERO_VEC_2
		end
		
		def friction(body, movement_direction)
			u = 0.5# Coefficient of friction
			# TODO: Calculate coefficient of friction by adding surface and entity components
			
			# Normal force
			# Currently assuming that all terrain is flat
			# TODO:	Update normal force to take account of terrain
			# 		Normal = mg*cos(theta)
			normal = body.m * @g
			
			movement_direction*u*normal*2 # g is negative, so the direction will be reversed
		end
	end
end
