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
			entity = arbiter.a.gameobj
			env = arbiter.b.gameobj
			
			entity_shape = arbiter.a
			env_shape = arbiter.b
			#Process actions involving what to do when on top, as well as side collisions
			
			#~ puts entity.pz
			#~ puts env.height(:meters)
			
			if entity.pz >= env.height(:meters)
				#If the entity collides from the side, accept the collision
				#~ puts entity.pz - entity.elevation
				#~ puts entity.pz - env.height(:meters)
				
				if env_shape.point_query entity_shape.body.local2world(CP::Vec2::ZERO)
					entity.set_elevation env.height(:meters)
				else
					arbiter.a.gameobj.reset_elevation arbiter.b.gameobj.height(:meters)
				end
				
				return false
			else
				#~ if entity.vz < 0
					#~ entity.set_elevation env.height(:meters)
				#~ end
				return true
			end
			
			#~ arbiter.a.gameobj.elevation = arbiter.b.gameobj.height(:meters)
			#~ entity.set_elevation env.height(:meters)
			#~ entity.raise_to_elevation
			#~ arbiter.a.gameobj.pz = arbiter.b.gameobj.height(:meters)
			#~ return false
		end
		
		#~ def post_solve(arbiter) #Do stuff after the collision has be evaluated
			#~ 
		#~ end
		#~ 
		def separate(arbiter)	#Stuff to do after the shapes separate
			
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
