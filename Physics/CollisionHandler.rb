#!/usr/bin/ruby
 
module CollisionHandler
	#a corresponds to the shape of the first type passed to add_collision_handler
	#b corresponds to the second

	#Control collisions between multiple Entity objects
	class Entity
		def begin(arbiter)
			return true
		end
		
		def pre(arbiter) #Determine whether to process collision or not
			#Process actions involving what to do when on top, as well as side collisions
			physics_a = arbiter.a.physics_obj
			physics_b = arbiter.b.physics_obj
			
			#First, determine which one is higher
			if physics_a.pz > physics_b.pz #a is higher
				higher = physics_a
				lower = physics_b
			elsif physics_a.pz < physics_b.pz	#b is higher
				lower = physics_a
				higher = physics_b
			else #They are at the same z position (z is a double, this will almost never happen)
				return true	#When two things are at the same z position, there should be a collision
			end
			
			#See if the higher one is high enough to pass over the lower one
			if higher.pz < lower.height
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
	class Entity_Env #Specify entity first, then the environment piece
		#~ def begin(arbiter,a,b)
			#~ return true
		#~ end
		
		def pre(arbiter) #Determine whether to process collision or not
			#Process actions involving what to do when on top, as well as side collisions
			if arbiter.a.physics_obj.pz < arbiter.b.physics_obj.height 
				#If the entity collides from the side, accept the collision
				return true
			else
				return false
			end
		end
		
		#~ def post_solve(arbiter) #Do stuff after the collision has be evaluated
			#~ 
		#~ end
		#~ 
		#~ def separate(arbiter)	#Stuff to do after the shapes separate
			#~ 
		#~ end
	end
	
	#~ Collision type for usage with the CP::Shape and CP::Body used for the camera
	#~ This is the collision handler for a sensor object
	class Camera
		#~ a has collision type :camera
		#~ b is the Chipmunk object for the Entity
		def begin(arbiter)
			$camera.add arbiter.b.entity
		end
				
		def separate(arbiter)
			$camera.delete arbiter.b.entity
		end
	end
end
