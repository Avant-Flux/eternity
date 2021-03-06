#!/usr/bin/ruby

# Methods that are used to manage Chipmunk attributes
# through the objects they are attached to, rather than the chipmunk objects.
module PhysicsInterface
	attr_reader :shape, :body, :height, :jump_count
	attr_accessor :running
	
	MAX_MOVEMENT_SPEED = 12
	
	def init_physics(collision_type, shape)
		@shape = shape
		@body = shape.body
		
		@shape.collision_type = collision_type
		
		@height = 2
		@jump_count = 0
		@jump_limit = 20000000000000000
		
		# @body.v_limit = 50
		#~ @body.w_limit = 100 # Limit rotational velocity
		
		@shape.u = 0.1
		
		@walk_force = 2000
		@run_force = 90000
		
		@running = false
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
		
		@body.a = @body.v.to_angle # NOTE: Not quite sure why checking for zero is unnecessary
		
		vec *= case type
			when :walk
				@walk_force
			when :run
				@run_force
		end
		
		# Reduce forces considerably if the Entity is in the air
		if @body.in_air?
			vec *= 0.1
		end
		if body.v.length > PhysicsInterface::MAX_MOVEMENT_SPEED
			body.v = body.v.clamp PhysicsInterface::MAX_MOVEMENT_SPEED
		else
			@body.apply_force vec, CP::ZERO_VEC_2
		end
	end
	
	def jump
		if @jump_count < @jump_limit #Do not exceed the jump count.
			@jump_count += 1
			@body.vz = 5 #On jump, set the velocity in the z direction
		end
	end
	
	def reset_jump
		@jump_count = 0
	end
	
	def warp(x,y,z)
		@body.p.x = x
		@body.p.y = y
		@body.pz = z
	end

	def add_to(space)
		space.add_shape @shape
		space.add_body @body
		
		# TODO:	Perform initial raycast when adding entity to space to determine
		# 		starting elevation.
	end
	
	def remove_from(space)
		space.remove_shape @shape
		space.remove_body @body
	end
end
