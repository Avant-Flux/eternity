#!/usr/bin/ruby

module Physics
	module SpaceVelocityFunctions
		#Create custom velocity and position functions for objects which respond to gravity. 
		
		# Precondition: Rise is positive.
		# Postcondition: Acceleration due to gravity is added to velocity.
		GRAVITY_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			physics_obj = body.physics_obj
			rise = physics_obj.pz - physics_obj.elevation
			
			if rise > 0
				body.update_velocity($space.g, $space.air_damping, dt)
			else #on_ground
				body.update_velocity(CP::ZERO_VEC_2, $space.air_damping, dt)
			end
		end
	end
	
	module SpacePositionFunctions
		GRAVITY_POSITION_FUNC = Proc.new do |body, dt|
			#When setting position, always set velocity as well.
			side_body = body.physics_obj.side.body
			bottom_body = body.physics_obj.bottom.body
			physics_obj = body.physics_obj
			
			rise = physics_obj.pz - physics_obj.elevation
			
			body.update_position dt
			
			# See if the object has collided with the ground.
				# This position should not go "below" the y coordinate designated by the 
				# bottom object.
			if rise < physics_obj.elevation
				if side_body.p.y > bottom_body.p.y - body.physics_obj.elevation
					# Set y equal to the level of the ground
						#Reset z-coordinate to be the same as the elevation
					#~ physics_obj.raise_to_elevation
					side_body.p.y = bottom_body.p.y - physics_obj.elevation
						
					# Reset the velocity and force so the same thing does not happen on the next frame
					side_body.v.y = 0
					side_body.f.y = 0
					bottom_body.v.y = 0
					
					# At this point, a collisions with the ground has been detected and resolved
					# Do things which need to be done on ground collision
					physics_obj.entity.resolve_ground_collision
					physics_obj.entity.resolve_fall_damage body.v.y
				end
			end
		end
	end
end
