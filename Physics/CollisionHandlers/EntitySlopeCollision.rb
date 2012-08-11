module CollisionHandler
	class EntitySlope < EntityEnv
		def pre_solve(arbiter) #Determine whether to process collision or not
			# Get game objects and shapes
			entity_shape = arbiter.a
			env_shape = arbiter.b
			
			entity = entity_shape.gameobject
			env = env_shape.gameobject
			
			#Process actions involving what to do when on top, as well as side collisions
			if entity.body.pz >= (elevation = env.height_at(entity.body.p.x, entity.body.p.y) + env.body.pz)
				# On top of the environment
				entity.body.elevation_queue.add env
				
				return false
			else
				# Feet are beneath elevation level
				if entity.body.pz < env.body.pz
					# Feet are beneath the z of the static object
					if entity.body.pz + entity.height > env.body.pz
						# Head is inside the static object (ie, colliding)
						entity.body.pz = env.body.pz - entity.height
						entity.body.vz = 0
						entity.body.az = 0
						return false
					else
						# Entity is below the static object
						return false
					end
				else
					# Less than elevation, greater than or equal to env.body.pz
					#~ puts "side collision"
					return true
				end
			end
		end
	end
end
