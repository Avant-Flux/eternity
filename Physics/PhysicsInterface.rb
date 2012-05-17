#!/usr/bin/ruby

# Methods that are used to manage Chipmunk attributes
# through the objects they are attached to, rather than the chipmunk objects.
module PhysicsInterface
	attr_reader :shape, :body, :height
	attr_accessor :pz, :vz, :az, :g
	attr_accessor :jump_count
	
	def init_physics(shape)
		@shape = shape
		@body = shape.body
		
		@height = 2
		
		# Create values for 3rd dimension of physics
		@elevation = 0	# Attempt to remove elevation if it is only needed for shadows
		@pz = 0
		@vz = 0 
		@az = 0
		@g = -9.8
		
		
		@jump_count = 0
	end

	def add_to(space)
		space.add_shape @shape
		space.add_body @body
	end
end
