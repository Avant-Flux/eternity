module CollisionHandler
	# Collision type for usage with the CP::Shape and CP::Body used for the camera
	# This is the collision handler for a sensor object
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
