module Physics
	module Movement
		# Keep in mind that the mix-ins in this package may turn out to be the same,
		# or one may be a special case of another.  If/when that happens, consolidate.
		
		
		# Precondition:		2D physics support, or 3D physics support 
		module Entity
			# Behavior for motion both on the ground, and in the air
			def init_movement
				# Both movement forces and maximum move velocity should be based on
				# the mobility stat.
				
				# Perhaps the movement interface should be controlled by setting acceleration and
				# velocity, not forces, as the forces needed to accelerate the body to a certain
				# point are relative to it's mass.
				# Or perhaps Mobility should be set to be dependent on Constitution and Level
				# 	This eliminates the problem of being able to create characters which are
				# 	both heavy, and highly mobile.
				# 	
				# 	Alternatively, there could be a Mobility/speed penalty for having high weight,
				# 	relative to one's constitution.
				# 		THIS SEEMS MORE LOGICAL
				#		
				#		relative to strength is probably better, as strength determines 
				#		carrying capacity.
				
				@movement_force = CP::Vec2::ZERO
				@walk_constant = 300
				@air_move_constant = 50
				@run_constant = 500
				
				# Need to also set max velocity in some way
				# The movement constants only use force, and thus dictate acceleration
				# May not want to actually use the v_limit though, as that will make the entity "resist"
				# 	being pushed around.
				@shape.body.v_limit = 5
				
				# To limit the velocity of an entity as it moves of it's own accord, set a target
				# velocity.  Once that target velocity is reached, additional force will only be
				# added to counteract the resistive forces, assuming the entity intends to move
				# in the direction of the velocity.  The force used to counter resistive
				# forces is bounded by the same force used to accelerate up to the target velocity
				# in the first place (ie, the movement force).
				@v_limit = 5;
			end
			
			def move(dir, resistive_force=nil)
				#~ if in_air?
				move_magnitude = if in_air?
					# Force for movement in air.
					# Should be less than ground movement force in most instances
					# 	if it's not, it sees like the character can fly
					# Needs to be enough to allow for jump modulation, and jumping forward from standstill
					@air_move_constant
				else
					# Force for movement on the ground
					@move_constant
				end
				
				# Generate force vector
				@movement_force = unit_vector(dir) * move_magnitude
				
				
				#~ # If the force to be applied is in the same direction as the current velocityv
				#~ if @movement_force.dot self.v > 0
					#~ # Then apply movement force only if the velocity is 
					#~ 
					#~ f_parallel = @movement_force.project self.v
					#~ # Create orthogonal vector, and project onto that
					#~ f_antiparallel = @movement_force.project self.v.perp
					#~ 
					#~ 
				#~ else
					#~ # Apply full measure of the force
					#~ 
				#~ end
				
				apply_force @movement_force
				
				
				
				
				self.a = unit_vector(dir).to_angle
			end
			
			def walk
				@move_constant = @walk_constant
			end
			
			def run
				@move_constant = @run_constant
			end
			
			private
			
			def unit_vector(direction)
				case direction
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
			end
		end
		
		module Projectile
			# Behavior for motion through the air only
			def init_movement
				
			end
		end
	end
end
