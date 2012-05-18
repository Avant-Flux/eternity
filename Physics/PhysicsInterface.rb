#!/usr/bin/ruby

# Methods that are used to manage Chipmunk attributes
# through the objects they are attached to, rather than the chipmunk objects.
module PhysicsInterface
	attr_reader :shape, :body, :height
	attr_accessor :jump_count
	
	def init_physics(shape)
		@shape = shape
		@body = shape.body
		
		@height = 2
		
		
		@jump_count = 0
	end
	
	def jump
		if @jump_count < 3 #Do not exceed the jump count.
			@jump_count += 1
			@body.vz = 5 #On jump, set the velocity in the z direction
		end
	end

	def add_to(space)
		space.add_shape @shape
		space.add_body @body
		
		# TODO:	Perform initial raycast when adding entity to space to determine
		# 		starting elevation.
	end
end
