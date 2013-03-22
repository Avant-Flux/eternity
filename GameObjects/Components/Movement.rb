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
			
			@physics.body.a = @physics.body.v.to_angle # NOTE: Not quite sure why checking for zero is unnecessary
			
			vec *= move_force
			
			# Reduce forces considerably if the Entity is in the air
			# TODO: Implement air dash
			if @physics.body.in_air?
				vec *= @air_force_control
			end
			
			# TODO: Differentiate between trying to accelerate past max speed, and trying to move against momentum
			# TODO: Consider using force to counter friction for movement instead of clamping speed
			if @physics.body.v.length > @max_movement_speed
				@physics.body.v = @physics.body.v.clamp @max_movement_speed
			else
				@physics.body.apply_force vec, CP::ZERO_VEC_2
			end
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
				# 710 # Counteract friction
				720
			elsif speed > 7
				1200
			elsif speed > 3
				1000
			else
				1700
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
				puts "TARGET === #{target_speed} ----- #{@run_speed}"
				
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
						
						puts @walk_animation.weight
						
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
