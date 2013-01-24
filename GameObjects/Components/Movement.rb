module Component
	class Movement
		MAX_MOVEMENT_SPEED = 12
		
		attr_reader :jump_count
		attr_accessor :running
		
		def initialize(physics, animation)
			@physics = physics
			@animation = animation
			
			@walk_force = 2000
			@run_force = 90000
			
			@running = false
			
			@jump_count = 0
			@jump_limit = 20000000000000000
		end
		
		
		# From PhysicsInterface
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
			if @physics.body.in_air?
				vec *= 0.1
			end
			if @physics.body.v.length > MAX_MOVEMENT_SPEED
				@physics.body.v = @physics.body.v.clamp MAX_MOVEMENT_SPEED
			else
				@physics.body.apply_force vec, CP::ZERO_VEC_2
			end
		end
		
		def jump
			if @jump_count < @jump_limit #Do not exceed the jump count.
				@jump_count += 1
				@physics.body.vz = 5 #On jump, set the velocity in the z direction
			end
		end
		
		def reset_jump
			@jump_count = 0
		end
	end
end