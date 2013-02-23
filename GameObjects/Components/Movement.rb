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
			# @animation[animation_name].weight = 1.5
			# Min influence
			# @animation[animation_name].weight = 0.5
			
			# Range = 1.5 - 0.5 = 1.0
			# @animation[animation_name].weight = @physics.body.v.length / 12 + 0.5
			
			name = "run"
			if speed > 6.5
				# Run
				# Some amount of run is playing
				@animation[name].enable
				
				# stride_length = 1		# in meters
				# stride_time = 0.4		# in seconds
				# run_speed = stride_length / stride_time	# Run rate at full speed playback
				
				run_speed = 2.8 # m / s
				# @animation[name].rate = speed / run_speed / 3.0
				@animation[name].rate = 1.0
			else
				@animation[name].disable
			end
			
			
			name = "walk_fast"
			if speed > 0.01 && speed < 6.5
				# Walk
				# Some amount of run is playing
				@animation[name].enable
				
				walk_speed = 2.8 # m / s
				@animation[name].rate = speed / walk_speed
			else
				@animation[name].disable
			end
			
			
			name = "idle"
			if speed <= 0.01
				# Idle
				# Must be in this state
				@animation[name].enable
			end
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
	end
end
