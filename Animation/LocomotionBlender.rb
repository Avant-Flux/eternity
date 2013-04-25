require 'state_machine'

class LocomotionBlender
	MOVEMENT_THRESHOLD = 0.01
	
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
	
	private
	
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