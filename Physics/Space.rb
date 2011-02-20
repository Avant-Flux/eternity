#!/usr/bin/ruby

module Physics
	class Space
		#Create custom velocity and position functions for objects which respond to gravity. 
		GRAVITY_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			body.update_velocity(Physics::Space.g, Physics::Space.air_damping, dt)
			
			#If the player hits the ground
			physics_obj = body.physics_obj
			if physics_obj.pz < physics_obj.elevation
				#Reset z-coordinate to be the same as the elevation
				physics_obj.pz = physics_obj.elevation
				#When setting position, always set velocity as well.
				physics_obj.vz = 0
				
				#Do things that need to be done when hitting the ground.
				physics_obj.entity.resolve_ground_collision
				physics_obj.entity.resolve_fall_damage body.v.y
			end
		end
		
		# Apply this function to the bottom object to get the side to move to compensate
		# and thus prevent wild fluctuations in z
		COMPENSATION_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			body.update_velocity(CP::ZERO_VEC_2, dmp, dt)
			
			#BUG does not allow jumping up-left.
			if body.rot.y != 0
				body.physics_obj.side.body.p.y += body.v.y*dt
			end
		end
		
		def initialize(dt, g = -9.8, surface_damping=0.12, air_damping=1, iterations=10)
			@space = CP::Space.new
			@space.damping = surface_damping
			@space.iterations = iterations
			@space.gravity = CP::ZERO_VEC_2
			
			@dt = dt
			@@g = CP::Vec2.new(0, g)
			@@air_damping = air_damping
			
			#~ @shapes = {:static = [], :nonstatic = []}
		end
		
		def step
			@space.step @dt
		end
		
		def add(physics_obj)
			#Add body to space
			@space.add_body physics_obj.bottom.body
			@space.add_body physics_obj.side.body
			
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? NonstaticObject
				# Add gravity function to body
				physics_obj.side.body.velocity_func = GRAVITY_VELOCITY_FUNC
				
				# Add compensation function (pseudo constraint)
				physics_obj.bottom.body.velocity_func = COMPENSATION_VELOCITY_FUNC
				
				# Add shapes to space
				@space.add_shape physics_obj.bottom
				@space.add_shape physics_obj.side
			else
				#Static objects also have a render object which must be added
				@space.add_body physics_obj.render_object.body
				
				# Add shapes to space
				@space.add_static_shape physics_obj.bottom
				@space.add_static_shape physics_obj.side
				@space.add_static_shape physics_obj.render_object
			end
		end
		
		def remove(physics_obj)
			#Add body to space
			@space.remove_body physics_obj.bottom.body
			@space.remove_body physics_obj.side.body
			
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? NonstaticObject
				#Object is nonstatic
				@space.remove_shape physics_obj.bottom
				@space.remove_shape physics_obj.side
			else
				#Object is static
				
				#Static objects also have a render object which must be added
				@space.remove_body physics_obj.render_object.body
				
				@space.remove_static_shape physics_obj.bottom
				@space.remove_static_shape physics_obj.side
				@space.remove_static_shape physics_obj.render_object
			end
		end
		
		def add_2D(obj)
			@space.add_shape obj.shape
			@space.add_body obj.shape.body
		end
		
		def remove_2D(obj)
			@space.remove_shape obj.shape
			@space.remove_body obj.shape.body
		end
		
		def find
			
		end
		
		def step
			@space.step @dt
		end
		
		def add_collision_handler(*args)
			@space.add_collision_handler *args
		end
		
		class << self
			def g
				@@g
			end
			
			def g=(arg)
				@@g
			end
			
			def air_damping
				@@air_damping
			end
			
			def air_damping=(arg)
				@@air_damping = arg
			end
		end
	end
end
