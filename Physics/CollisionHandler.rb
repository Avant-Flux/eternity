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
			# Get game objects and shapes
			entity_shape = arbiter.a
			env_shape = arbiter.b
			
			entity = entity_shape.gameobject
			env = env_shape.gameobject
			
			#Process actions involving what to do when on top, as well as side collisions
			if entity.body.pz >= (elevation = env.height + env.body.pz)
				# On top of the environment
				#~ puts "over"
				
				#~ if entity.body.pz >= elevation && elevation > entity.body.elevation
					#~ entity.body.add_elevation elevation
				#~ end
				entity.body.elevation_queue.add env
				
				return false
			else
				# Feet are beneath elevation level
				if entity.body.pz < env.body.pz
					# Feet are beneath the z of the static object
					if entity.body.pz + entity.height > env.body.pz
						# Head is inside the static object (ie, colliding)
						#~ puts "head collision"
						entity.body.pz = env.body.pz - entity.height
						entity.body.vz = 0
						entity.body.az = 0
						return false
					else
						# Entity is below the static object
						#~ puts "beneath"
						return false
					end
				else
					# Less than elevation, greater than or equal to env.body.pz
					#~ puts "side collision"
					#~ if elevation > entity.body.elevation
						return true
					#~ else
						#~ return false
					#~ end
				end
			end
		end
		
		#~ def post_solve(arbiter) #Do stuff after the collision has be evaluated
			#~ 
		#~ end
		
		def separate(arbiter)	#Stuff to do after the shapes separate
			#~ arbiter.a.gameobj.reset_elevation arbiter.b.gameobj.height(:meters) + arbiter.b.gameobj.pz
			
			# Get game objects and shapes
			entity_shape = arbiter.a
			env_shape = arbiter.b
			
			entity = entity_shape.gameobject
			env = env_shape.gameobject
			
			#~ elevation = env.height + env.body.pz
			#~ entity.body.delete_elevation elevation
			entity.body.elevation_queue.delete env
		end
	end
	
	#~ Collision type for usage with the CP::Shape and CP::Body used for the camera
	#~ This is the collision handler for a sensor object
	class Camera
		#~ a has collision type :camera
		#~ b is the Chipmunk object for the Entity
		def begin(arbiter)
			arbiter.a.add arbiter.b.gameobject
			false
		end
				
		def separate(arbiter)
			arbiter.a.delete arbiter.b.gameobject
		end
	end
end
