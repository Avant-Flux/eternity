module CollisionHandler
	#Control collisions between an Entity and the environment
	#	ie, a character and a building or land mass
	class EntityEnv #Specify entity first, then the environment piece
		def begin(arbiter)
			return true
		end
		
		def pre_solve(arbiter) #Determine whether to process collision or not
			# Get game objects and shapes
			entity_shape = arbiter.a
			env_shape = arbiter.b
			
			entity = entity_shape.gameobject
			env = env_shape.gameobject
			
			puts "COLLIDE"
			return true
			
			#Process actions involving what to do when on top, as well as side collisions
			if entity.physics.body.pz >= (elevation = env.physics.height + env.physics.body.pz)
				# On top of the environment
				entity.physics.body.elevation_queue.add env
				
				return false
			else
				# Feet are beneath elevation level
				if entity.physics.body.pz < env.physics.body.pz
					# Feet are beneath the z of the static object
					if entity.physics.body.pz + entity.physics.height > env.physics.body.pz
						# Head is inside the static object (ie, colliding)
						entity.physics.body.pz = env.physics.body.pz - entity.physics.height
						entity.physics.body.vz = 0
						entity.physics.body.az = 0
						return false
					else
						# Entity is below the static object
						return false
					end
				else
					# Less than elevation, greater than or equal to env_body.pz
					#~ puts "side collision"
					return true
				end
			end
		end
		
		#~ def post_solve(arbiter) #Do stuff after the collision has be evaluated
			#~ 
		#~ end
		
		def separate(arbiter)	#Stuff to do after the shapes separate
			# Get game objects and shapes
			entity_shape = arbiter.a
			env_shape = arbiter.b
			
			entity_body = entity_shape.body
			env_body = env_shape.body
			
			entity = entity_shape.gameobject
			env = env_shape.gameobject
			
			entity_body.elevation_queue.delete env
		end
	end
end
