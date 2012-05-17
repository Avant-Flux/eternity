#!/usr/bin/ruby

require 'set'

module Physics
	class Space < CP::Space
		def initialize
			super()
			
			self.iterations = 10
			self.damping = 0.2
			
			@t_previous = Gosu.milliseconds
			
			@bodies = Set.new()
		end
		
		def add_body(body)
			super(body)
			
			@bodies.add body
		end
		
		def add_shape(shape)
			super(shape)
			
			
		end
		
		def step
			dt = timestep()
			
			super(dt) # Timestep in seconds
			
			# Iteration for third dimension
			@bodies.each do |body|
				body.vz += body.az * dt
				body.pz += body.vz * dt
				if body.pz < body.elevation
					body.pz = body.elevation
					body.vz = 0
					body.az = 0
					
					body.gameobject.resolve_ground_collision
				elsif body.pz > body.elevation
					# TODO: Change conditional to be if in_air? to handle uneven terrain
					# Apply gravity
					body.vz += body.g * dt
					body.pz += body.vz * dt
				else
					# Currently on the ground
				end
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
	end
end
