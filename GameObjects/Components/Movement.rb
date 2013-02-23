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
			
			if @physics.body.v.length < 0.01
				# Effectively still
				@animation["walk_fast"].disable
				@animation["run"].disable
				
				@animation["idle"].enable
			else
				# Moving
				# NOTE: Blending "idle" (breathing animation) with motion actually looks cool
				@animation["idle"].disable
				
				# Max influence
				# @animation[animation_name].weight = 1.5
				# Min influence
				# @animation[animation_name].weight = 0.5
				
				# Range = 1.5 - 0.5 = 1.0
				# @animation[animation_name].weight = @physics.body.v.length / 12 + 0.5
				
				run_speed_threshold = 6.5
				
				v = @physics.body.v.length
				if v > run_speed_threshold
					# Run
					# stride_length = 1		# in meters
					# stride_time = 0.4		# in seconds
					# run_speed = stride_length / stride_time	# Run rate at full speed playback
					
					run_speed = 2.8 # m / s
					# @animation["run"].rate = @physics.body.v.length / run_speed / 3.0
					# @animation["run"].rate = 1.0
					
					# Transition into run
					unless @animation["run"].enabled?
						@animation["run"].enable
						
						@animation["walk_fast"].disable
						# @animation["run"].weight = 1.0
						# @animation["run"].time = 0
					end
				else
					# Walk
					# Set speed of animation relative to step rate
					# stride_length = 1		# in meters
					# stride_time = 0.4		# in seconds
					# walk_speed = stride_length / stride_time	# Walk rate at full speed playback
					
					# Transition from run
					# if @animation["run"].enabled?
						@animation["run"].disable
					# end
					
					# unless @animation["walk_fast"].enabled?
						# Transition into walk
						@animation["walk_fast"].enable
					# end
					
					# If walk is active
					walk_speed = 2.8 # m / s
					@animation["walk_fast"].rate = @physics.body.v.length / walk_speed
				end
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
