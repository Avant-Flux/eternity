#!/usr/bin/ruby

module Physics
	module SpaceVelocityFunctions
		#Create custom velocity and position functions for objects which respond to gravity. 
		GRAVITY_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			physics_obj = body.physics_obj
			
			if physics_obj.pz > physics_obj.elevation
				#~ physics_obj.set_elevation
				body.update_velocity($space.g, $space.air_damping, dt)
				
			else
				#Reset z-coordinate to be the same as the elevation
				#When setting position, always set velocity as well.
				physics_obj.reset_forces
				physics_obj.vz = 0
				physics_obj.raise_to_elevation
				
				
				#Do things that need to be done when hitting the ground.
				physics_obj.entity.resolve_ground_collision
				physics_obj.entity.resolve_fall_damage body.v.y
				#~ 
				body.update_velocity(CP::ZERO_VEC_2, $space.air_damping, dt)
			end
		end
		
		# Apply this function to the bottom object to get the side to move to compensate
		# and thus prevent wild fluctuations in z
		COMPENSATION_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			body.update_velocity(CP::ZERO_VEC_2, dmp, dt)
			
			#BUG does not allow jumping up-left.
			if body.rot.y != 0
				body.physics_obj.side.body.p.y += body.v.y*dt
			end
		end
	end
end
