require 'state_machine'

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
		
		MOVEMENT_THRESHOLD = 0.01
		
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
			
			# # TODO: Differentiate between trying to accelerate past max speed, and trying to move against momentum
			# # TODO: Consider using force to counter friction for movement instead of clamping speed
			# if @physics.body.v.length > @max_movement_speed
			# 	@physics.body.v = @physics.body.v.clamp @max_movement_speed
			# else
			# 	@physics.body.apply_force vec, CP::ZERO_VEC_2
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
				720
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
					600
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
			angle = @physics.body.a
			@physics.body.apply_force angle.radians_to_vec2 * move_force, CP::ZERO_VEC_2
		end
		
		def rotate_to_heading
			# Rotate body towards heading
			angle_bound = 0.1
			angle = @heading.to_angle
			
			# puts "angle: #{@physics.body.a}"
			# puts "w: #{@physics.body.w}"
			# puts "f: #{@physics.body.f}"
			
			
			# if @physics.body.a > Math::PI * 2
			# 	@physics.body.a = Math::PI * 2
			# elsif @physics.body.a < 0
			# 	@physics.body.a = 0
			# end
			
			# @physics.body.a %= Math::PI * 2
			
			
			# If close enough to heading, lock at heading (double imprecision)
			# Make sure to check if we have already overshot the heading
			on_course =	if @physics.body.a.between? angle - angle_bound, angle + angle_bound
							true
						else
							# Check if the target angle has been overshot
							if @sign
								if @sign > 0
									# Positive
									if @physics.body.a > angle + angle_bound
										true # overshot, lock to "on course" position
									else
										false # good
									end
								elsif @sign < 0
									# Negative
									if @physics.body.a < angle - angle_bound
										true # overshot, lock to "on course" position
									else
										false # good
									end
								end
							else
								false
							end
						end
			
			
			
			if on_course
				# The body is headed in the target direction
				puts "ON COURSE"
				# @physics.body.w = 0
				@physics.body.a = angle
			else
				# Not headed in the target direction
			
				# simplified: 2 multiplications, one addition, and sqrt
				# actually: 4 multiplications, 2 additions, 1 sqrt
				# cos is closer to 1 as velocity gets closer to heading
				cos = @heading.dot @physics.body.v.normalize
				cos = 1.0 if cos >= 0.99 # snap to 1.0 if close enough
					# More mathematically sound variant for 3+ dimensions
					# sin(theta) = |u x v|/(|u| * |v|)
					# cross_mag = @heading.cross @physics.body.v
					# simplified: 2 sqrt, 1 division
					# actually: 4 multiplications, 2 additions, 1 division, 1 sqrt
					# sin = (cross_mag)/(@heading.length * @physics.body.v.length)
				
				# Using this method, cw is pos, ccw is negative
				# 	cw means heading x velocity = positive
				# 	this would only happen if velocity is ccw relative to heading
				# 	thus, the perceived "flip"
				cross = @heading.cross @physics.body.v
				@sign = if cross > 0.0
					# sign is positive
					-1
				elsif cross < 0.0
					# sign is negative
					1
				else
					nil
				end
				
				# puts "cos #{cos}"
				# puts "sign #{sign}"
				
				# for a given target X, what A must be applied to reach that X in time T?
				# 1/2*at^2 + vt + x = x_target
				# acceleration is thus dependent on current velocity, as well as distance to target
				
				# Given:
				#  current rotation
				#  current torque
				#  target rotation
				# what torque must be applied to counter the torque before the destination?
				#
				# basically, what A will counter A_current before a target value of X?
				#  at that point, acceleration and velocity must be 0
				#  x == target
				
				# Key the torque the same way the move force is keyed
				
				# Negative is CW
				# Positive is CCW
				# @physics.body.torque += sign * 200
				@physics.body.torque += @sign * move_torque if @sign
			end
		end
		
		class LocomotionBlender
			attr_reader :idle_animation, :walk_animation, :run_animation
			attr_reader :timers
			
			def initialize(idle, walk, run)
				super()
				
				@idle_animation = idle
				@walk_animation = walk
				@run_animation = run
				
				@timers = {
					:walk => Timer.new(0.68)
				}
				
				# Note: It is advised to not exceed 50% distortion
				# less distortion results in a smoother blend
				# but 0% distortion assumes infinitesimal samples (too smooth of a blend)
				allowed_distortion = 0.3
				
				@b = 0.0				# starting value of property - weight of run/walk
				@c = 1.0-@b			# change in value of property - weight of run/walk
				
				run_stride_length = 2.75		# in meters
				# run_stride_time = 48.frames		# in seconds
				@run_speed = run_stride_length / @run_animation.length * 2	# Run rate at full speed playback
				
				walk_stride_length = 5.5/4		# in meters
				# walk_stride_time = 48.frames		# in seconds
				@walk_speed = walk_stride_length / @walk_animation.length * 2	# Walk rate at full speed
				
				
				# TODO: Raise exception if in_speed is higher than out_speed, warning of distortion threshold being too high
				# TODO: Raise exception for in_speed lower than @walk_speed (prev tier in speed)
				
				# rate = speed / @animation_speed
				# 1.5 = target_speed / @animation_speed
				# target_speed = 1.5 * @animation_speed
				
				target_rate = 1.0 + allowed_distortion
				target_speed = target_rate * @walk_speed
				# puts "TARGET === #{target_speed} ----- #{@run_speed}"
				
				@in_speed = target_speed
				@out_speed = @run_speed
			end
			
			# TODO: First step of blend (from idle to walk) should be distortion dependent
			# actually, probably not, because the distortion effects the in speed, which for idle->walk should be as low as possible. (ideally zero, but floating point precision problems)
			# TODO: Generalize to n-way crossfader
			
			def update(dt, speed)
				# Handle state transitions
				if speed > @out_speed
					run
				elsif speed > @in_speed
					walk_to_run
					run_to_walk
				elsif speed > @walk_speed
					walk
				elsif speed > MOVEMENT_THRESHOLD
					# Only one of these should fire, determined by the state machine
					walk_to_idle
					idle_to_walk
				else
					# transition to idle if walk is done blending out
					idle
				end
				
				# puts "===== #{state}"
				# puts "idle: #{@idle_animation.enabled?}"
				# puts "walk: #{@walk_animation.enabled?}"
				# puts "run: #{@run_animation.enabled?}"
				# puts "=========="
				
				# Play animation based on current state
				play dt, speed
			end
			
			# TODO: POLISH - Need sneaking animation
			
			state_machine :state, :initial => :idling do
				state :idling do
					def play(dt, speed)
						@idle_animation.enable
						@walk_animation.disable
						@run_animation.disable
						
						@idle_animation.weight = 1.0
					end
				end
				
				state :crossfading_idle_walk do
					def play(dt, speed)
						# Starting to walk
						@idle_animation.enable
						@walk_animation.enable
						@run_animation.disable
						
						# TODO: Alter starting weight to match position in step.  Always take the same amount of time to blend.
						
						# Crossfade animations
						easing = Oni::Animation::Ease.in_quad(
										@walk_animation.weight,
										speed - MOVEMENT_THRESHOLD,
										b = 0.2,
										c = 1.0 - b,
										@walk_speed - MOVEMENT_THRESHOLD
									)
						
						@idle_animation.weight = 1.0 - easing
						@walk_animation.weight = easing
						
						# Clamp values
						@idle_animation.weight = @idle_animation.weight.clamp(0.0, 1.0)
						@walk_animation.weight = @walk_animation.weight.clamp(0.0, 1.0)
						
						# puts @walk_animation.weight
						
						@walk_animation.rate = speed / @walk_speed
					end
				end
				
				state :walking do
					def play(dt, speed)
						@idle_animation.disable
						@walk_animation.enable
						@run_animation.disable
						
						@walk_animation.weight = 1.0
						# @run_animation.weight = 0.0
						
						@walk_animation.rate = speed / @walk_speed
					end
				end
				
				state :crossfading_walk_run do
					def play(dt, speed)
						@idle_animation.disable
						@walk_animation.enable
						@run_animation.enable
						
						# Sync locomotion rates so blending works correctly
						@run_animation.rate = speed / @run_speed
						@walk_animation.rate = @run_animation.rate
						
						# Crossfade animations
						easing = Oni::Animation::Ease.in_quad(
										@run_animation.weight, speed - @in_speed,
										@b,
										@c,
										@out_speed - @in_speed
									)
						
						@run_animation.weight = easing
						@walk_animation.weight = 1.0 - easing
					end
				end
				
				state :crossfading_run_walk do
					def play(dt, speed)
						@idle_animation.disable
						@walk_animation.enable
						@run_animation.enable
						
						# Sync locomotion rates so blending works correctly
						@walk_animation.rate = speed / @walk_speed
						@run_animation.rate = @walk_animation.rate
						
						# Crossfade animations
						easing = Oni::Animation::Ease.in_quad(
										@run_animation.weight, speed - @in_speed,
										@b,
										@c,
										@out_speed - @in_speed
									)
						
						@run_animation.weight =  easing
						@walk_animation.weight = 1.0 - easing
						
						@idle_animation.weight = @idle_animation.weight.clamp(0.0, 1.0)
						@walk_animation.weight = @walk_animation.weight.clamp(0.0, 1.0)
					end
				end
				
				state :running do
					def play(dt, speed)
						@idle_animation.disable
						@walk_animation.disable
						@run_animation.enable
						
						@run_animation.weight = 1.0
						
						@run_animation.rate = speed / @run_speed
					end
				end
				
				
				
				# before_transition any => :idling do |blender|
				# 	blender.idle_animation.enable
					
				# 	blender.walk_animation.disable
				# 	blender.run_animation.disable
				# end
				
				before_transition any => :crossfading_idle_walk do |blender|
					# Timer tracks time left in crossfade from walk to idle
					blender.timers[:walk].reset
				end
				
				before_transition :walking => :crossfading_walk_run do |blender|
					# ===== Transition into run
					blender.run_animation.enable
					# Sync walk and run playback
					# Currently walking, that should drive the blend
					blender.run_animation.time = blender.walk_animation.time
				end
				
				before_transition :running => :crossfading_run_walk do |blender|
					blender.walk_animation.enable
					# Sync walk and run playback
					# Currently running, that should drive the blend
					blender.walk_animation.time = blender.run_animation.time
				end
				
				
				
				# TODO: Need to be able to transition back to idle on sudden stop - ie hitting wall
				event :idle do
					transition :crossfading_idle_walk => :idling
				end
				
				event :idle_to_walk do
					transition :idling => :crossfading_idle_walk
				end
				
				event :walk_to_idle do
					transition :walking => :crossfading_idle_walk
				end
				
				event :walk do
					transition [:crossfading_idle_walk, :crossfading_walk_run, :crossfading_run_walk] => :walking
				end
				
				event :walk_to_run do
					transition :walking => :crossfading_walk_run
				end
				
				event :run_to_walk do
					transition :running => :crossfading_run_walk
				end
				
				event :run do
					transition [:crossfading_walk_run, :crossfading_run_walk] => :running
				end
			end
		end
		
		class Timer
			attr_reader :duration, :time
			
			def initialize(duration)
				@duration = duration
				
				@time = 0.0
			end
			
			def update(dt)
				@time += dt
			end
			
			def ended?
				return @time >= @duration
			end
			
			def reset
				@time = 0.0
			end
		end
	end
end
