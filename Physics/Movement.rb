module Physics
	module Movement
		module Entity
			# Behavior for motion both on the ground, and in the air
			def init_movement
				@movement_force = CP::Vec2::ZERO
				@walk_constant = 300
				@air_move_constant = 50
				@run_constant = 500
				
				# Need to also set max velocity in some way
				# The movement constants only use force, and thus dictate acceleration
				# May not want to actually use the v_limit though, as that will make the entity "resist"
				# 	being pushed around.
				@shape.body.v_limit = 5
			end
		end
		
		module Projectile
			# Behavior for motion through the air only
			def init_movement
				
			end
		end
	end
end
