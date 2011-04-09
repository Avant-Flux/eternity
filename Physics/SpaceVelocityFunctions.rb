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
				#Hit ground
				
				#~ puts 1
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
				#In air
			
				#~ puts 2
				body.update_velocity($space.g, $space.air_damping, dt)
				
			elsif rise > lower_bound && rise < upper_bound
				#On ground
			
				#~ puts 3
				body.update_velocity(CP::ZERO_VEC_2, $space.air_damping, dt)
				if physics_obj.side.body.p.y > physics_obj.bottom.body.p.y
					if body.v.y > 0
						#If the position of the side is lower on the screen than of the bottom object
						physics_obj.side.body.p.y = physics_obj.bottom.body.p.y
						physics_obj.side.body.v.y = 0
						physics_obj.bottom.body.reset_forces
						physics_obj.bottom.body.v.y = 0
					end
				end
			end
			
			
		end
		
		# Apply this function to the bottom object to get the side to move to compensate
		# and thus prevent wild fluctuations in z
		COMPENSATION_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			body.update_velocity(CP::ZERO_VEC_2, dmp, dt)
			
			#BUG does not allow jumping up-left.
			#~ if body.v.y != 0
				#~ body.physics_obj.side.body.v.y -= body.v.y + (body.f.y/body.m)*(dt)
				#~ body.physics_obj.side.body.v.y += body.v.y
			if body.v.y > 0
				body.physics_obj.side.body.p.y += body.v.y*dt
			end
			
			#~ side_body = body.physics_obj.side.body
			#~ 
			#~ if (body.physics_obj.pz > 0.015)# && (side_body.v.y > 10 || side_body.v.y < -0.01)
				#~ side_body.p.y += body.v.y*dt + (body.f.y/body.m)*(dt**2)
				#~ side_body.v.y += body.v.y
			#~ end
		end
	end
end
