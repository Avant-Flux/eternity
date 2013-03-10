module CollisionHandler
	#Control collisions between multiple Entity objects
	class Entity
		def begin(arbiter)
			return true
		end
		
		def pre_solve(arbiter) #Determine whether to process collision or not
			#Process actions involving what to do when on top, as well as side collisions
			a_shape = arbiter.a
			b_shape = arbiter.b
			
			a_obj = a_shape.gameobject
			b_obj = b_shape.gameobject
			
			physics_a = a_obj.physics
			physics_b = b_obj.physics
			
			#First, determine which one is higher
			case physics_a.body.pz <=> physics_b.body.pz
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
			if higher.body.pz < lower.height + lower.body.pz
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
end
