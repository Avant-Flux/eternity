require 'tween'

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
			movement_threshold = 0.01
			
			blend_run_animation		dt, speed, movement_threshold
			blend_walk_animation	dt, speed, movement_threshold
			blend_idle_animation	dt, speed, movement_threshold
			
			# ["run", "walk", "idle"].each do |name|
			# 	puts name if @animation[name].enabled?
			# end
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
			
			vec *= case type
				when :walk
					@walk_force
				when :run
					@run_force
			end
			
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
		
		private
		
		def blend_run_animation(dt, speed, movement_threshold)
			animation = @animation["run"]
			
			if speed > 6.5
				animation.enable
				
				# Run
				# Some amount of run is playing
				
				# stride_length = 1		# in meters
				# stride_time = 0.4		# in seconds
				# run_speed = stride_length / stride_time	# Run rate at full speed playback
				
				run_speed = 2.8 # m / s
				# animation.rate = speed / run_speed / 3.0
				animation.rate = 1.0
			else
				animation.disable
			end
		end
		
		def blend_walk_animation(dt, speed, movement_threshold)
			animation = @animation["walk"]
			
			if speed > movement_threshold
				animation.enable
				@time = nil # Stop fade out, if any
				
				# Walk
				# Some amount of walk is playing
				
				# stride_length = 1		# in meters
				# stride_time = 0.4		# in seconds
				# walk_speed = stride_length / stride_time	# Walk rate at full speed playback
				
				walk_speed = 2.8 # m / s
				animation.rate = speed / walk_speed
				
				if speed > 6.5
					animation.weight = 0.0
				else
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
				
				if animation.enabled?
					# Time varies from 0 to d
					@time ||= 0
					
					if @time
						@time += dt
						b = 0.0 # starting value of property
						c = 1.0 # change in value of property
						d = 1.0 # duration of the tween
						
						# animation.weight = 1.0 - Tween::Linear.ease(@time, b,c,d)
						animation.weight = 1.0 - Tween::Cubic::Out.ease(@time, b,c,d)
						puts animation.weight
						
						if @time >= d
							# Tween is done
							@time = nil
							animation.weight = 1.0
							animation.disable
							puts "OFF"
						end
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
		
		def blend_idle_animation(dt, speed, movement_threshold)
			animation = @animation["idle"]
			
			if speed <= movement_threshold
				animation.enable
				
				# Idle
				# Must be in this state
				
				# @animation["walk"].
			else
				animation.disable
			end
		end
	end
end
