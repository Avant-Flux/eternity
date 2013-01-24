module CollisionHandler
	class EntitySlope < EntityEnv
		def pre_solve(arbiter) #Determine whether to process collision or not
			# Get game objects and shapes
			entity_shape = arbiter.a
			env_shape = arbiter.b
			
			entity_body = entity_shape.body
			env_body = env_shape.body
			
			entity = entity_shape.gameobject
			env = env_shape.gameobject
			
			#Process actions involving what to do when on top, as well as side collisions
			if entity_body.pz >= env.height_at(entity_body.p.x, entity_body.p.y) + env_body.pz
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
					# Only accept as side collision if the center of the entity is outside the
					# cross section of the ramp.
					if env_shape.point_query(entity_body.p)
						return false
					else
						return true
					end
				end
			end
		end
	end
end
