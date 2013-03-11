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
			
			# Timers for various properties.
			# key:		symbol
			# value:	double - time
			@timers = {
				:walk => Timer.new(0.68)
			}
			
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
			# animation.weight = @physics.body.v.length / 12 + 0.5
			
			speed = @physics.body.v.length
			
			
			# blend_run_animation		dt, speed
			# blend_walk_animation	dt, speed
			# blend_idle_animation	dt, speed
			
			
			# locomotion_blending(dt, speed)
			
			
			@blender.update dt, speed
			
			
			
			# p speed
		end
		
		def move(direction, type)
			#~ puts direction
			
			vec = case direction
				when :up
					CP::Vec2.new(0,1)
				when :down
					CP::Vec2.new(0,-1)
				when :left
					CP::Vec2.new(-1,0)
				when :right
					CP::Vec2.new(1,0)
				when :up_right
					CP::Vec2.new(1,1).normalize!
				when :up_left
					CP::Vec2.new(-1,1).normalize!
				when :down_right
					CP::Vec2.new(1,-1).normalize!
				when :down_left
					CP::Vec2.new(-1,-1).normalize!

			end
			
			@physics.body.a = @physics.body.v.to_angle # NOTE: Not quite sure why checking for zero is unnecessary
			
			vec *= move_force
			
			# Reduce forces considerably if the Entity is in the air
			# TODO: Implement air dash
			if @physics.body.in_air?
				vec *= @air_force_control
			end
			
			# TODO: Differentiate between trying to accelerate past max speed, and trying to move against momentum
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
			end
		end
		
		def reset_jump
			@jump_count = 0
		end
		
		def move_force
			speed = @physics.body.v.length
			
			if speed > 9
				710 # Counteract friction
			elsif speed > 7
				1200
			elsif speed > 3
				1000
			else
				1700
			end
		end
		
		private
		
		def locomotion_blending(dt, speed)
			run = @animation["run"]
			walk = @animation["walk"]
			idle = @animation["idle"]
			
			in_speed = 4
			out_speed = 6
			
			b = 0.0				# starting value of property
			c = 1.0-b			# change in value of property
			
			run_stride_length = 2.75		# in meters
			# run_stride_time = 48.frames		# in seconds
			run_speed = run_stride_length / run.length * 2	# Run rate at full speed playback
			
			walk_stride_length = 5.5/4		# in meters
			# walk_stride_time = 48.frames		# in seconds
			walk_speed = walk_stride_length / walk.length * 2	# Walk rate at full speed 
			
			
			
			if speed >= out_speed
				# Full run
				run.weight = 1.0
				run.rate = speed / run_speed
				
				# thus, no walk
				walk.disable
				walk.weight = 0.0
			elsif speed > in_speed
				# Blending between run and walk
				walk.enable
				
				# Modulate run
				unless run.enabled?
					# ===== Transition into run
					run.enable
					# Sync with walk playback
					# walk.time = run.time
					run.time = walk.time
				end
				
				
				# walk.rate = speed / walk_speed
				# run.rate = walk.rate
				
				run.rate = speed / run_speed
				walk.rate = run.rate
				
				easing = Oni::Animation::Ease.in_quad(
								run.weight, speed - in_speed,
								b,
								c,
								out_speed - in_speed
							)
				
				run.weight = easing
				walk.weight = 1.0 - easing
			elsif speed <= in_speed && speed > MOVEMENT_THRESHOLD
				# Full walk
				unless walk.enabled?
					# On transition to this state
					walk.enable
					walk.weight = 1.0
					
					walk.time = 0
					
					# Walk state
					@state = :walk
					@timers[:walk].reset
				end
				
				walk.rate = speed / walk_speed
				
				# thus, no run
				run.disable
				run.weight = 0.0
				
				# and no idle
				idle.disable
			else
				# Blend out
				# Transition to idle
				
				# Start timer if the animation is playing
				# One time transition to new state
				if walk.enabled?
					# Time varies from 0 to d
					@state = :walk_out
				end
				
				# Blend while the timer is active
				# Blend-out state
				if @state == :walk_out
					idle.enable
					
					@timers[:walk].update dt
					
					# TODO: Alter starting weight to match position in step.  Always take the same amount of time to blend.
					
					easing = Oni::Animation::Ease.in_out_cubic(
								walk.weight,
								@timers[:walk].time,
								b = 0.0,					# starting value of property
								c = 1.0-b,					# change in value of property
								@timers[:walk].duration		# duration of the tween
							)
					idle.weight = easing
					walk.weight = 1.0 - easing
					puts walk.weight
					
					if @timers[:walk].ended?
						# Tween is done
						# Transition to Idle state
						@state = :idle
						
						@timers[:walk].reset
						
						walk.weight = 1.0
						walk.disable
						puts "OFF"
					end
				elsif @state == :idle
					idle.enable
				end
			end
		end
		
		def blend_run_animation(dt, speed)
			animation = @animation["run"]
			
			in_speed = 5
			out_speed = 6
			
			b = 0.0				# starting value of property
			c = 1.0-b			# change in value of property
			
			if speed > in_speed # Some degree of Run active
				unless animation.enabled?
					animation.enable
					# Sync with walk playback
					animation.time = @animation["walk"].time
				end
				
				# Run
				# Some amount of run is playing
				
				stride_length = 2.75		# in meters
				stride_time = 48.frames		# in seconds
				# walk_speed = stride_length / stride_time	# Walk rate at full speed 
				run_speed = stride_length / animation.length * 2	# Run rate at full speed playback
				
				# run_speed = 2.8 # m / s
				# animation.rate = speed / run_speed / 3.0
				animation.rate = speed / run_speed
				# animation.rate = 1.0
				
				
				
				if speed > out_speed
					# Full on
					animation.weight = 1.0
				elsif speed > in_speed
					# Some on
					
					influence = Oni::Animation::Ease.in_quad(
											animation.weight, speed-in_speed,
											b,
											c,
											out_speed - in_speed
										)
					animation.weight = influence
				else
					# Full off
					animation.weight = 0.0
				end
			else
				animation.disable
			end
		end
		
		def blend_walk_animation(dt, speed)
			animation = @animation["walk"]
			
			in_speed = 5
			out_speed = 6
			
			b = 0.0				# starting value of property
			c = 1.0-b			# change in value of property
			
			if speed > MOVEMENT_THRESHOLD
				# Walk state
				@state = :walk
				@timers[:walk].reset
				animation.enable
				
				# Walk
				# Some amount of walk is playing
				
				stride_length = 5.5/4			# in meters
				# stride_time = 48.frames		# in seconds
				# walk_speed = stride_length / stride_time	# Walk rate at full speed 
				walk_speed = stride_length / animation.length * 2	# Walk rate at full speed playback
				
				# walk_speed = 2.8 # m / s
				animation.rate = speed / walk_speed
				
				if speed > out_speed
					# Totally out
					animation.weight = 0.0
				elsif speed > in_speed
					# Transition
					influence = 1.0-Oni::Animation::Ease.in_quad(
											animation.weight, speed-in_speed,
											b,
											c,
											out_speed - in_speed
										)
					animation.weight = influence
					
					
					
					
					# Sync speed with Run speed
					stride_length = 2.75		# in meters
					stride_time = 48.frames		# in seconds
					# walk_speed = stride_length / stride_time	# Walk rate at full speed 
					run_speed = stride_length / animation.length * 2	# Run rate at full speed playback
					
					# run_speed = 2.8 # m / s
					# animation.rate = speed / run_speed / 3.0
					animation.rate = speed / run_speed
				else
					# Totally in
					animation.weight = 1.0
				end
			else
				# Blend out
				# animation.weight = Oni::Animation::ease_in(x, t, b,c,d)
				# a = 0.01 # lower bound
				# b = 0.65 # upper bound
				# Normalize
				# x = (speed-a)/(b-a)
				
				# # Fade in
				# animation.weight = (animation.weight + dt * rate).clamp 0, 1
				
				# Fade out
				# animation.weight = (animation.weight - dt * rate).clamp 0, 1
				
				# TODO: POLISH - Need first step and walk to neutral
				# fade_in = 1
				# fade_out = -1
				# fade_type = fade_out
				
				# rate = 5.0 # weight per second
				# # rate = 1.0
				# animation.weight += fade_type * dt * rate
				
				
				# Start timer if the animation is playing
				# One time transition to new state
				if animation.enabled?
					# Time varies from 0 to d
					@state = :walk_out
				end
				
				# Blend while the timer is active
				# Blend-out state
				if @state == :walk_out
					@timers[:walk].update dt
					
					# TODO: Alter starting weight to match position in step.  Always take the same amount of time to blend.
					b = 0.0							# starting value of property
					c = 1.0-b						# change in value of property
					d = @timers[:walk].duration		# duration of the tween
					
					animation.weight = 1.0 - Oni::Animation::Ease.out_cubic(
												animation.weight, @timers[:walk].time, b,c,d
											)
					puts animation.weight
					
					if @timers[:walk].ended?
						# Tween is done
						# Transition to Idle state
						@state = :idle
						
						@timers[:walk].reset
						
						animation.weight = 1.0
						animation.disable
						puts "OFF"
					end
				end
				
				# animation.timer end_time, dt, do |time|
				# 	# Block to set properties according
				# 	animation.weight = 1.0 - Tween::Cubic::In.ease(time, 0.0,1.0,d)
				# end
				
				# # Stop fading
				# animation.cance_fade
				# animation.cancel_fade_out
				# animation.cance_fade_in
				
				# animation.tween :weight, 5.frames do |normalized|
				# 	# value at the end of the block is the new influence
				# 	normalized
				# end
			end
		end
		
		def blend_idle_animation(dt, speed)
			animation = @animation["idle"]
			
			if speed <= MOVEMENT_THRESHOLD
				animation.enable
				
				# Idle
				# Must be in this state
				
				# @animation["walk"].
			else
				animation.disable
			end
		end
		
		class LocomotionBlender
			attr_reader :idle_animation, :walk_animation, :run_animation
			attr_reader :timers
			
			MOVEMENT_THRESHOLD = 0.01
			
			def initialize(idle, walk, run)
				super()
				
				@idle_animation = idle
				@walk_animation = walk
				@run_animation = run
				
				@timers = {
					:walk => Timer.new(0.68)
				}
				
				
				@in_speed = 4
				@out_speed = 6
				
				@b = 0.0				# starting value of property
				@c = 1.0-@b			# change in value of property
				
				run_stride_length = 2.75		# in meters
				# run_stride_time = 48.frames		# in seconds
				@run_speed = run_stride_length / @run_animation.length * 2	# Run rate at full speed playback
				
				walk_stride_length = 5.5/4		# in meters
				# walk_stride_time = 48.frames		# in seconds
				@walk_speed = walk_stride_length / @walk_animation.length * 2	# Walk rate at full speed 
				
			end
			
			def update(dt, speed)
				# puts state
				
				# Handle state transitions
				if speed >= @out_speed
					puts "transition to RUN"
					run
				elsif speed > @in_speed
					puts "transition to walk/run blend"
					walk_to_run
				elsif speed > MOVEMENT_THRESHOLD + 1.5
					puts "transition to walk"
					walk
				elsif speed > MOVEMENT_THRESHOLD
					puts "blending idle and walk"
					# Only one of these should fire, determined by the state machine
					# walk_to_idle
					idle_to_walk
				else
					idle
				end
				
				puts state
				
				# Play animation based on current state
				play
			end
			
			state_machine :state, :initial => :idling do
				state :idling do
					def play
						@idle_animation.enable						
					end
				end
				
				state :crossfading_idle_walk do
					def play
						@idle_animation.disable
					end
					# Starting to walk
					
					
					# idle.enable
					
					# @timers[:walk].update dt
					
					# # TODO: Alter starting weight to match position in step.  Always take the same amount of time to blend.
					
					# easing = Oni::Animation::Ease.in_out_cubic(
					# 			walk.weight,
					# 			@timers[:walk].time,
					# 			b = 0.0,					# starting value of property
					# 			c = 1.0-b,					# change in value of property
					# 			@timers[:walk].duration		# duration of the tween
					# 		)
					# idle.weight = easing
					# walk.weight = 1.0 - easing
					# puts walk.weight
				end
				
				state :crossfading_walk_idle do
					def play
						# # Stopping walk and transitioning to standstill
						# @idle_animation.enable
						
						# @timers[:walk].update dt
						
						# # TODO: Alter starting weight to match position in step.  Always take the same amount of time to blend.
						
						# easing = Oni::Animation::Ease.in_out_cubic(
						# 			@walk_animation.weight,
						# 			@timers[:walk].time,
						# 			b = 0.0,					# starting value of property
						# 			c = 1.0-b,					# change in value of property
						# 			@timers[:walk].duration		# duration of the tween
						# 		)
						# @idle_animation.weight = easing
						# @walk_animation.weight = 1.0 - easing
						# puts @walk_animation.weight
					end
				end
				
				state :walking do
					def play
						# @walk_animation.enable
						
						# @walk_animation.rate = speed / @walk_animation_speed
						
						# # thus, no run
						# @run_animation.disable
						# @run_animation.weight = 0.0
						
						# # and no idle
						# @idle_animation.disable
					end
				end
				
				state :crossfading_walk_run do
					def play
						# # walk.rate = speed / @walk_speed
						# # run.rate = walk.rate
						
						# @run_animation.rate = speed / @run_speed
						# @walk_animation.rate = run.rate
						
						# easing = Oni::Animation::Ease.in_quad(
						# 				@run_animation.weight, speed - @in_speed,
						# 				@b,
						# 				@c,
						# 				@out_speed - @in_speed
						# 			)
						
						# @run_animation.weight = easing
						# @walk_animation.weight = 1.0 - easing
					end
				end
				
				state :running do
					def play
						# @run_animation.enable
						
						# # Full run
						# @run_animation.weight = 1.0
						# @run_animation.rate = speed / @run_speed
						
						# # thus, no walk
						# @walk_animation.disable
						# @walk_animation.weight = 0.0
					end
				end
				
				
				
				
				before_transition any => :crossfading_idle_walk do |blender|
					blender.timers[:walk].reset # Timer tracks time left in crossfade from walk to idle
				end
				
				# TODO: Perhaps use before_transition here? Not sure what the difference is
				after_transition :crossfading_idle_walk => :idling do |blender|
					# Tween is done
					# Transition to Idle state
					
					blender.walk_animation.weight = 1.0
					blender.walk_animation.disable
					puts "OFF"
				end
				
				before_transition :crossfading_idle_walk => :walking do |blender|
					# On transition to walking
					blender.walk_animation.enable
					blender.walk_animation.weight = 1.0
					
					blender.walk_animation.time = 0
				end
				
				before_transition :walking => :crossfading_walk_run do |blender|
					# ===== Transition into run
					blender.run_animation.enable
					# Sync with walk playback
					# walk.time = run.time
					blender.run_animation.time = blender.walk_animation.time
				end
				
				
				
				
				event :idle do
					transition [:crossfading_walk_idle, :crossfading_idle_walk] => :idling
				end
				
				event :idle_to_walk do
					transition :idling => :crossfading_idle_walk
				end
				
				event :walk_to_idle do
					transition :walking => :crossfading_walk_idle
				end
				
				event :walk do
					transition :crossfading_idle_walk => :walking
				end
				
				event :walk_to_run do
					transition :walking => :crossfading_walk_run
				end
				
				event :run do
					transition :crossfading_walk_run => :running
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
