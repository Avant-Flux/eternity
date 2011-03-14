#!/usr/bin/ruby

module Physics
	module SpaceVelocityFunctions
		#Create custom velocity and position functions for objects which respond to gravity. 
		GRAVITY_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			physics_obj = body.physics_obj
			rise = physics_obj.pz - physics_obj.elevation
			
			upper_bound = 0.0015
			lower_bound = -0.01
			
			if rise < lower_bound
				puts 1
				#Reset z-coordinate to be the same as the elevation
				#When setting position, always set velocity as well.
				physics_obj.reset_forces
				physics_obj.side.body.reset_forces
				physics_obj.vz = 0
				physics_obj.raise_to_elevation
				
				
				#Do things that need to be done when hitting the ground.
				physics_obj.entity.resolve_ground_collision
				physics_obj.entity.resolve_fall_damage body.v.y
			elsif rise > upper_bound
				#~ puts 2
				body.update_velocity($space.g, $space.air_damping, dt)
			elsif rise > lower_bound && rise < upper_bound
				#~ puts 3
				body.update_velocity(CP::ZERO_VEC_2, $space.air_damping, dt)
			end
			
			
			#~ case physics_obj.pz - physics_obj.elevation <=> 0.15
				#~ when -1
					#~ puts -1
					#~ #Reset z-coordinate to be the same as the elevation
					#~ #When setting position, always set velocity as well.
					#~ physics_obj.reset_forces
					#~ physics_obj.side.body.reset_forces
					#~ physics_obj.vz = 0
					#~ physics_obj.raise_to_elevation
					#~ 
					#~ 
					#~ #Do things that need to be done when hitting the ground.
					#~ physics_obj.entity.resolve_ground_collision
					#~ physics_obj.entity.resolve_fall_damage body.v.y
				#~ when 0
					#~ puts 0
					#~ body.update_velocity(CP::ZERO_VEC_2, $space.air_damping, dt)
				#~ when 1
					#~ puts 1
					#~ body.update_velocity($space.g, $space.air_damping, dt)
			#~ end
		end
		
		# Apply this function to the bottom object to get the side to move to compensate
		# and thus prevent wild fluctuations in z
		COMPENSATION_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			body.update_velocity(CP::ZERO_VEC_2, dmp, dt)
			
			#BUG does not allow jumping up-left.
			#~ if body.v.y != 0
				#~ body.physics_obj.side.body.v.y -= body.v.y + (body.f.y/body.m)*(dt)
				#~ body.physics_obj.side.body.v.y += body.v.y
				#~ body.physics_obj.side.body.p.x += body.v.x*dt + (body.f.x/body.m)*(dt**2)
			#~ end
		end
	end
end
