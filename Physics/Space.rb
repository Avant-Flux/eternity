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
				#~ puts body.v.length
				apply_friction body, @dt
				
				#~ apply_resistive_force body, @dt
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
		
		def apply_friction(body, dt)
			# Try applying force integration to velocity "manually",
			# without using #apply_force
			#
			# If that doesn't work, just use damping, at least for now.  It's not worth the time.
			# 	Damping can not be used with the current structure.  Forces would need to be reset.
			# 	every frame for every object for damping to mimic friction in that way.
			# 
			# Currently friction force can not reverse the direction of an object.
			# 	This is caused by the magnitude of the force of friction not being 
			# 	allowed to exceed the net force in the direction of friction.
			
			# Apply a resistive force in the opposite direction of the velocity
			magnitude = body.v.length
			puts "v: #{body.v.length}  f: #{body.f.length}"
			if magnitude > 0.2 # Only apply resistive forces if object is in motion
				puts "moving"
				
				# Friction should be in the opposite direction of velocity
				# Parallel, but opposite sign
				direction_vector = body.v / magnitude
				
				# TODO: Implement the following block as a true function
				resistive_force = if body.pz > body.elevation # if body.in_air?
					# Air resistance
					
					# Pseudo-return
					CP::ZERO_VEC_2
				else
					# Friction
					u = 0.7 # Coefficient of friction
					# TODO: Calculate coefficient of friction by adding surface and entity components
					
					# Normal force
					# Currently assuming that all terrain is flat
					# TODO:	Update normal force to take account of terrain
					# 		Normal = mg*cos(theta)
					normal = body.m * @g
					
					# Pseudo-return
					direction_vector*u*normal
				end
				
				
				# Acceleration is a vector
				a = resistive_force/body.m
				v  = a*dt
				
				#~ puts v
				
				body.v += v
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
					new_elevation = env.height + env.pz
					
					if new_elevation > elevation
						elevation = new_elevation
					end
				end
			end
			
			return elevation
		end
	end
end
