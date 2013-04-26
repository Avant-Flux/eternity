class Numeric
	# Convert from frames to seconds
	def frames(framerate=60.hz)
		return self*framerate
	end
	
	# Convert to herts
	def hz
		return 1.0/self
	end
	
	def clamp(min, max)
		if self < min
		  return min
		elsif max < self
		  return max
		else
		 	return self
		end
	end
end

module Component
	class Movement
		attr_reader :jump_count
		attr_accessor :running
		
		attr_accessor :max_movement_speed
		attr_accessor :walk_force, :run_force
		
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
			
			@running = false
			
			@jump_velocity = opts[:jump_velocity]
			@jump_count = 0
			@jump_limit = opts[:jump_limit]
			
			
			# Variables to track rotation of the character
			@heading = CP::Vec2.new(0,0) # direction the player is trying to go
			@heading_halfway = CP::Vec2.new(0,0) # # halfway to the heading. this is so the code can track when to stop speeding up the rotation and start to slow down
			@rotation = :none # :ccw, :cw, :none
			
			
			@blender = LocomotionBlender.new	@animation["idle"], 
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
			
			@blender.update dt, speed
			
			
			apply_movement_force
			
			
			
			# Reset heading vector
			@heading.x = 0
			@heading.y = 0
		end
		
		def move(direction, type)
			# Input specifies intent of heading
			# Rotate towards heading
				# use torque to rotate towards heading?
			# always accelerate in direction of heading
			# with this system, it is easy to increase forces if heading in opposite direction of current movement, or similar 
			#
			# should be allowed to specify right and up in separate move calls
			# and still behave as expected
			
			
			# create new heading vector
			# create new half-way-to-heading vector
			# torque torwards heading
			# 	speed up until half way, then start to slow down
			
			vec = case direction
				when :up
					CP::Vec2.new(0,1)
				when :down
					CP::Vec2.new(0,-1)
				when :left
					CP::Vec2.new(-1,0)
				when :right
					CP::Vec2.new(1,0)
			end
			
			@heading += vec
			@heading.normalize! unless @heading == CP::ZERO_VEC_2
			# puts "heading: #{@heading}"
			
			# vec *= move_force
			
			# # Reduce forces considerably if the Entity is in the air
			# # TODO: Implement air dash
			# if @physics.body.in_air?
			# 	vec *= @air_force_control
			# end
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
					if @physics.body.f.length > 0.0 # perhaps use heading instead?
						direction = @physics.body.f.normalize
						direction *= 5
						@physics.body.v = direction
					end
				end
			end
		end
		
		def reset_jump
			@jump_count = 0
		end
		
		def move_force
			speed = @physics.body.v.length
			
			if speed > 9
				# @physics.body.friction(@g, @u) # Counteract friction (currently 710)
				# NOTE: This ^ will cause slight acceleration in air because there is no friction.
				710
			elsif speed > 7
				1200
			elsif speed > 3
				1000
			else
				1700
			end
		end
		
		def move_torque
			w = @physics.body.w
			w *= -1 if w < 0.0 # insure value is positive
			
			# Rotation speed should be proportional to movement speed
				# or is it movement force?
				# point is, overall momentum should be altered more drastically at higher velocity
			
			
			if @physics.body.in_air?
				# Spin faster if airborne
				if w > (2*Math::PI * 2)
					@physics.body.resistive_torque(-9.8) # Counteract friction
				else
					300
				end
			else
				# On the ground
				
				# Accelerate to particular rotational velocity, then hold that velocity
				if w > (2*Math::PI * 1/2)
					@physics.body.resistive_torque(-9.8) # Counteract friction
				else
					200
				end
			end
		end
		
		private
		
		def apply_movement_force
			# Process movement in #update, as movement forces should only be applied once per frame
			# Rotational motion:
			# tau = dL/dt			(change in angular momentum over time)
			# tau_net = I*alpha
			# -- similar to F = ma
			
			# chipmunk has no "apply_torque" function, so it may be better to just figure out how to apply forces to the body properly to generate the required angular acceleration
			
			# @physics.body.a = @physics.body.v.to_angle # vec(0,0) points down pos x axis
			
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
			
			rotate_to_heading
			
			# Move "forward" - in the direction the character is currently facing
			# Apply force in the direction the character is currently visually facing
			@physics.body.apply_force @physics.body.a.radians_to_vec2 * move_force, CP::ZERO_VEC_2
			
			
			# TODO: Fix bug which causes character to do a 360 spin before hitting destination angle. Only seems to occur at certain velocities.  May have to do with extra centripetal force.
			
			# apply additional centripetal force for tighter turning
			r = nil
			if @physics.body.torque > 0
				# CCW
				# Go left
				a_vec = @physics.body.a.radians_to_vec2
				r = CP::Vec2.new(-a_vec.y, a_vec.x) # perpendicular vector
			elsif @physics.body.torque < 0
				# CW
				# Go right
				a_vec = @physics.body.a.radians_to_vec2
				r = CP::Vec2.new(a_vec.y, -a_vec.x) # perpendicular vector
			end
			if r
				@physics.body.apply_force r * move_force*0.5, CP::ZERO_VEC_2
			end
		end
		
		def rotate_to_heading
			heading_normal = CP::Vec2.new(-@heading.y, @heading.x)
			
			dot = @physics.body.a.radians_to_vec2.dot heading_normal
			
			rotation = if dot > 0
				-1 # CW
			else
				1 # CCW
			end
			
			@physics.body.torque += rotation * move_torque
		end
	end
end
