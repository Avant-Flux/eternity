module Physics
	module Movement
		# Keep in mind that the mix-ins in this package may turn out to be the same,
		# or one may be a special case of another.  If/when that happens, consolidate.
		
		
		# Precondition:		2D physics support, or 3D physics support 
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
			
			def move(dir)
				unit_vector =	case dir
									when :up
										Physics::Direction::N
									when :down
										Physics::Direction::S
									when :left
										Physics::Direction::W
									when :right
										Physics::Direction::E
									when :up_left
										Physics::Direction::NW
									when :up_right
										Physics::Direction::NE
									when :down_left
										Physics::Direction::SW
									when :down_right
										Physics::Direction::SE
								end
				
				#~ if in_air?
				if pz > elevation
					# Apply force for movement in air.
					# Should be less than ground movement force in most instances
					# 	if it's not, it sees like the character can fly
					# Needs to be enough to allow for jump modulation, and jumping forward from standstill
					@movement_force = unit_vector * @air_move_constant
				else
					# Apply force for movement on the ground
					@movement_force = unit_vector * @move_constant
				end
				
				apply_force @movement_force
				
				self.a = unit_vector.to_angle
			end
			
			def walk
				@move_constant = @walk_constant
			end
			
			def run
				@move_constant = @run_constant
			end
		end
		
		module Projectile
			# Behavior for motion through the air only
			def init_movement
				
			end
		end
	end
end
