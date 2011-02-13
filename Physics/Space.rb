#!/usr/bin/ruby

module Physics
	class Space
		#Create custom velocity and position functions for objects which respond to gravity. 
		GRAVITY_VELOCITY_FUNC = Proc.new do |body, g, dmp, dt|
			body.update_velocity(Physics::Space.g, dmp, dt)
		end
		#~ GRAVITY_POSITION_FUNC = Proc.new do |body, dt|
			#~ body.update_position(dt)
				#body->p = cpvadd(body->p, cpvmult(cpvadd(body->v, body->v_bias), dt));
				#cpBodySetAngle(body, body->a + (body->w + body->w_bias)*dt);
				#
				#body->v_bias = cpvzero;
				#body->w_bias = 0.0f;
			#~ 
			#~ #Ensure the z-coord of the entity does not drop below zero
			#~ body.p.y = 0 if body.p.y < 0 
		#~ end
		
		def initialize(dt, g = -9.8, damping=0.12, iterations=10)
			@space = CP::Space.new
			@space.damping = damping
			@space.iterations = iterations
			
			@dt = dt
			@@g = CP::Vec2.new(0, g)
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
				physics_obj.side.velocity_func = GRAVITY_VELOCITY_FUNC
				#~ physics_obj.side.position_func = GRAVITY_POSITION_FUNC
			
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
		
		class << self
			def g
				@@g.y
			end
			
			def g=(arg)
				@@g.y = arg
			end
		end
	end
end
