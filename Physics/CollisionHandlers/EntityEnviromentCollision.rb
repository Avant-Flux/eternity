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
			
			entity_body = entity_shape.body
			env_body = env_shape.body
			
			entity = entity_shape.gameobject
			env = env_shape.gameobject
			
			#Process actions involving what to do when on top, as well as side collisions
			if entity_body.pz >= (elevation = env.height + env_body.pz)
				# On top of the environment
				entity_body.elevation_queue.add env
				
				return false
			else
				# Feet are beneath elevation level
				if entity_body.pz < env_body.pz
					# Feet are beneath the z of the static object
					if entity_body.pz + entity.height > env_body.pz
						# Head is inside the static object (ie, colliding)
						entity_body.pz = env_body.pz - entity.height
						entity_body.vz = 0
						entity_body.az = 0
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
