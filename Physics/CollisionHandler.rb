#!/usr/bin/ruby
 
module CollisionHandler
	#a corresponds to the shape of the first type passed to add_collision_handler
	#b corresponds to the second

	#Control collisions between multiple Entity objects
	class Entity
		def begin(arbiter)
			return false
		end
		
		def pre(arbiter) #Determine whether to process collision or not
			#Process actions involving what to do when on top, as well as side collisions
			physics_a = arbiter.a.physics_obj
			physics_b = arbiter.b.physics_obj
			
			#First, determine which one is higher
			case physics_a.pz <=> physics_b.pz
				when -1
					lower = physics_a
					higher = physics_b
				when 0
					return true
				when 1
					higher = physics_a
					lower = physics_b
			end
			
			#See if the higher one is high enough to pass over the lower one
			if higher.pz < lower.height + lower.pz
				#The higher of the two is not high enough to clear the other one
				return true
			else
				#The higher one was high enough.  Ignore the collision so the higher can pass 
				#"though" (read: over) the lower one.
				return false
			end
		end
		
		#~ def post_solve(arbiter, a, b) #Do stuff after the collision has be evaluated
			#~ 
		#~ end
		#~ 
		#~ def separate(arbiter, a, b)	#Stuff to do after the shapes separate
			#~ 
		#~ end
	end
	
	#Control collisions between an Entity and the environment
	#	ie, a character and a building or land mass
	class EntityEnv #Specify entity first, then the environment piece
		def begin(arbiter)
			return true
		end
		
		def pre_solve(arbiter) #Determine whether to process collision or not
			# Set collision normals so that collisons with the environment are calculated correctly
			#~ case arbiter.normal(0)
				#~ when CP::Vec2.new(0,-1)
					#~ arbiter.normal(0) = Physics::Direction::Y_HAT
			#~ end
			
			# Get game objects and shapes
			entity = arbiter.a.gameobj
			env = arbiter.b.gameobj
			
			entity_shape = arbiter.a
			env_shape = arbiter.b
			
			#Process actions involving what to do when on top, as well as side collisions
			
			if entity.pz >= env.height(:meters) + env.pz
				#If the entity collides from the side, accept the collision
				if env_shape.point_query entity_shape.body.local2world(CP::Vec2::ZERO)
					entity.set_elevation env.height(:meters) + env.pz
				end
				
				return false
			elsif entity.pz < env.pz
				if entity.height(:meters) > env.pz
					# Feet are below the bottom surface of the environment,
					# but the head is colliding
					entity.pz = env.pz - entity.height(:meters)
					entity.vz = 0
					entity.fz = 0
				end
				
				if entity.pz + entity.height(:meters) < env.pz
					return false
				else
					#~ return true
				end
				
				
				#~ if entity.height(:meters) < env.pz
					#~ return false
				#~ else
					#~ return true
				#~ end
			
			#~ elsif entity.height(:meters) < env.pz
				#~ # Pass underneath
				#~ 
				#~ return false
			#~ else
				#~ # Determine which side the collision is coming from,
				#~ # and then apply the appropriate normal force
				#~ 
				#~ return true
			else
				# Correct collision normals
				correct_collision_normals(arbiter)
				return true
			end
		end
		
		#~ def post_solve(arbiter) #Do stuff after the collision has be evaluated
			#~ 
		#~ end
		
		def separate(arbiter)	#Stuff to do after the shapes separate
			#~ arbiter.a.gameobj.reset_elevation arbiter.b.gameobj.height(:meters) + arbiter.b.gameobj.pz
		end
		
		private
		
		def correct_collision_normals(arbiter)
			entity = arbiter.a.gameobj
			env = arbiter.b.gameobj
			
			entity_shape = arbiter.a
			env_shape = arbiter.b
			
			if arbiter.normal(0) == CP::Vec2.new(0,-1)
				# Collide with South face
				y = entity.fy_
				if y > 0
					f = Physics::Direction::Y_HAT * -y
					entity_shape.body.apply_force f, CP::ZERO_VEC_2
				end
			elsif (arbiter.normal(0).x - Physics::Direction::Y_HAT.y).abs <= 0.00000001 &&
			(arbiter.normal(0).y + Physics::Direction::Y_HAT.x).abs <= 0.00000001
				# Collide with East face
				x = entity.fx_
				if x < 0
					f = Physics::Direction::X_HAT * -x
					entity_shape.body.apply_force f, CP::ZERO_VEC_2
				end
			elsif arbiter.normal(0) == CP::Vec2.new(0,1)
				# Collide with North face
				y = entity.fy_
				if y < 0
					f = Physics::Direction::Y_HAT * -y
					entity_shape.body.apply_force f, CP::ZERO_VEC_2
				end
			elsif (arbiter.normal(0).x + Physics::Direction::Y_HAT.y).abs <= 0.00000001 &&
			(arbiter.normal(0).y - Physics::Direction::Y_HAT.x).abs <= 0.00000001
				# Collide with West face
				x = entity.fx_
				if x > 0
					f = Physics::Direction::X_HAT * -x
					entity_shape.body.apply_force f, CP::ZERO_VEC_2
				end
			end
		end
	end
	
	# Used for the tops of non-moving environmental pieces and buildings
	class EntityEnvTop
		def begin(arbiter)
			return false
		end
		
		#~ def pre(arbiter) #Determine whether to process collision or not
			#~ return true
			#~ #Process actions involving what to do when on top, as well as side collisions
			#~ physics_a = arbiter.a.physics_obj
			#~ physics_b = arbiter.b.physics_obj
			#~ 
			#~ if physics_a.pz - physics_b.height < -0.15
				#~ #If the entity collides from the side, accept the collision
				#~ puts arbiter.a.physics_obj.pz - arbiter.a.physics_obj.elevation
				#~ puts arbiter.a.physics_obj.pz - arbiter.b.physics_obj.height
				#~ return true
			#~ else
				#~ physics_a.set_elevation
				#~ return false
			#~ end
		#~ end
		
		#~ def post_solve(arbiter) #Do stuff after the collision has be evaluated
			#~ 
		#~ end
		#~ 
		#~ def separate(arbiter)	#Stuff to do after the shapes separate
			#~ arbiter.a.physics_obj.set_elevation
		#~ end
	end
	
	#~ Collision type for usage with the CP::Shape and CP::Body used for the camera
	#~ This is the collision handler for a sensor object
	class Camera
		#~ a has collision type :camera
		#~ b is the Chipmunk object for the Entity
		def begin(arbiter)
			arbiter.a.add arbiter.b.gameobj
			false
		end
				
		def separate(arbiter)
			arbiter.a.delete arbiter.b.gameobj
		end
	end
end
