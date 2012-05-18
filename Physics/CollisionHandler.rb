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
			
			if entity.body.pz >= (elevation = env.height + env.pz)
				# On top of the environment
				#~ puts "over"
				#~ if env_shape.point_query entity_shape.body.local2world(CP::Vec2::ZERO)
					#~ entity.body.elevation = env.height + env.pz
				#~ end
				
				if 	(entity.body.pz >= elevation && elevation > entity.body.elevation)
					entity.body.elevation = elevation
				end
				
				
				return false
			elsif entity.body.pz < env.pz - entity.height
				if entity.body.pz + entity.height > env.pz
					# Feet are below the bottom surface of the environment,
					# but the head is colliding
					entity.body.pz = env.pz - entity.height
					entity.body.vz = 0
					entity.body.az = 0
					return false
				elsif entity.body.pz + entity.height <= env.pz
					# Entity is below the environment object
					return false
				else
					#~ return true
				end
			else
				# Collide on the side
				return true
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
			
			entity.body.elevation = 0
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
			arbiter.a.add arbiter.b.gameobject
			false
		end
				
		def separate(arbiter)
			arbiter.a.delete arbiter.b.gameobject
		end
	end
end
