class Numeric
	def clamp(min, max)
		if self < min
		  return min
		elsif max < self
		  return max
		else
		 	return self
		end
	end
	
	# Snap to certain value if close enough
	def snap(value, error)
		if self.between? value - error, value + error
			value 
		else
			self
		end
	end
end

module Component
	class Movement
		attr_reader :jump_count
		attr_accessor :running
		
		attr_accessor :max_movement_speed
		attr_accessor :walk_force, :run_force
		
		attr_reader :locomotion
		
		DEFAULT_OPTIONS = {
			:max_movement_speed => 12,
			:air_force_control => 1.0,
			
			:walk_force => 0,
			:run_force => 0,
			
			:jump_velocity => 5,
			:jump_limit => 1
		}
		
		def initialize(physics, animation, opts={})
			opts = DEFAULT_OPTIONS.merge opts
			
			@physics = physics
			@animation = animation
			
			# ===== Constraints =====
			@max_movement_speed = opts[:max_movement_speed]
			# Percentage of force to be applied in-air
			@air_force_control = opts[:air_force_control]
			
			# ===== Constants ===== 
			# --- mathematical sense, not programming sense
			@walk_force = opts[:walk_force]
			@run_force = opts[:run_force]
			
			@jump_velocity = opts[:jump_velocity]
			@jump_count = 0
			@jump_limit = opts[:jump_limit]
			
			
			@heading = CP::Vec2.new(0,0) # direction the player is trying to go
			@move_type = :walk # :walk, :run (specifies rate of motion)
			
			@locomotion = LocomotionBlender.new	@animation["idle"], 
												@animation["walk"],
												@animation["run"]
		end
		
		def update(dt)
			# Walk speed modulation notes
			# What is walk speed? (like, velocity)
			# 	stride length, step time (time elapsed for one step)
			# Should have a baseline walk speed, and then speed up or down from there
			# 	How much can you scale without distorting? - no distortion
			# 	Better to speed up or slow down? - shouldn't matter
			# Scale step rate linearly with velocity
			# Blending "idle" (breathing animation) with motion actually looks cool
			
			# Max influence
			# animation.weight = 1.5
			# Min influence
			# animation.weight = 0.5
			# Range = 1.5 - 0.5 = 1.0
			
			speed = @physics.body.v.length
			puts speed
			
			@locomotion.update dt, speed
			
			
			apply_movement_force
			
			# Reset heading vector
			@heading.x = 0
			@heading.y = 0
		end
		
		def move(direction, type)
			# Input specifies intent of heading
			# Rotate towards heading
			# always accelerate in direction of heading
			# with this system, it is easy to increase forces if heading in opposite direction of current movement, or similar 
			#
			# should be allowed to specify right and up in separate move calls
			# and still behave as expected
			
			@move_type = type
			
			vec = case direction
				when :up
					Physics::NORTH
				when :down
					Physics::SOUTH
				when :left
					Physics::WEST
				when :right
					Physics::EAST
			end
			
			@heading += vec
			@heading.normalize! unless @heading == CP::ZERO_VEC_2
			# puts "heading: #{@heading}"
		end
		
		def jump
			if @jump_count < @jump_limit #Do not exceed the jump count.
				@jump_count += 1
				@physics.body.vz = @jump_velocity #On jump, set the velocity in the z direction
				
				
				# -- Air jumps propel in desired direction, allowing for fast change of direction
				# NOTE: Will also effect when body is being pushed
				# If currently in air
				# and If there is a force on body (trying to move)
				# add a bunch of velocity in that direction on jump
				# 
				# Velocity added should be related to move force in some way
				# or more properly, move acceleration?
				# Don't want characters to jump considerably faster than walking
				# 	or do you? might be good to present movement through air as effortless and fast
				# 	may be better to just limit air jump time
				# 	hints at abilities of Wind/Storm characters, and how fun it could be
				# 	
				# 	increased helplessness after double jump?
				# 		reduce ability to change jump arc after the first in-air jump
				# perhaps reduced verticality when pressing direction and jumping?
				# 	essentially, long jump instead of high jump
				if @physics.body.in_air?
					if @physics.body.v.length > 0.0 # perhaps use heading instead?
						# puts "JUMP"
						@physics.body.v = @physics.body.f.normalize * @physics.body.v.length
					end
				end
			end
		end
		
		def reset_jump
			@jump_count = 0
		end
		
		def move_force
			speed = @physics.body.v.length
			
			force = case @move_type
				when :walk
					# puts "walk"
					if speed > 9
						# Currently in run-level speed
						# Slow down
						@physics.body.friction(9.8, 0.5).length / 100 # fraction of force of friction
					elsif speed > 6.5
						# Outside of normal walking speed,
						# but acceptable range for slowing down after run
						@physics.body.friction(9.8, 0.5).length # counter friction
					elsif speed > 6
						# @physics.body.friction(@g, @u) # Counteract friction (currently 710)
						# NOTE: This ^ will cause slight acceleration in air because there is no friction.
						# 710
						@physics.body.friction(9.8, 0.5).length
					elsif speed > 3
						1000
					else
						1700
					end
				when :run
					# puts "run"
					if speed > 9
						@physics.body.friction(9.8, 0.5).length # negate friction
					else
						1300
					end
			end
			
			if @physics.body.in_air?
				return force * @air_force_control
			else
				return force
			end
		end
		
		private
		
		def apply_movement_force
			# Process movement in #update, as movement forces should only be applied once per frame
			# Rotational motion:
			# tau = dL/dt			(change in angular momentum over time)
			# tau_net = I*alpha
			# -- similar to F = ma
			
			# Movement rules are different in air
			# when in air, the character should have limited movement in the horizontal plane
			# character rotates exponentially towards the direction specified by heading, in order to allow the player to turn for a backwards attack, or a mid-air jump
				# exponential rotation allows for easily making close-to-current angle jumps (slow)
				# or jumps in the target direction (locked limit of rotation)
			
			# chipmunk has no "apply_torque" function, so it may be better to just figure out how to apply forces to the body properly to generate the required angular acceleration
			
			# If the body is supposed to move, it should have a heading
			if @heading == CP::ZERO_VEC_2
				return # just exit the method, nothing to see here
			end
			
			# Clamp movement speed at maximum possible speed (speed of light-style speed limit)
			# TODO: Differentiate between trying to accelerate past max speed, and trying to move against momentum
			# TODO: Consider using force to counter friction for movement instead of clamping speed
			if @physics.body.v.length > @max_movement_speed
				@physics.body.v = @physics.body.v.clamp @max_movement_speed
			end
			
			@physics.body.a = @physics.body.v.to_angle
			
			# Snap to heading angle if close enough to remove stutter
			# @physics.body.a = @physics.body.a.snap @heading.to_angle, 2*Math::PI * 1/720
			
			@physics.body.apply_force @heading * move_force, CP::ZERO_VEC_2
			
			# TODO: Fix bug which causes character to do a 360 spin before hitting destination angle. Only seems to occur at certain velocities.  May have to do with extra centripetal force.
		end
	end
end
