#!/usr/bin/ruby
 
module PhysicsInterface
	#Assume only that the class this is mixed-in to has the variable @shape defined
	#	@shape is some class in CP::Shape_3D
	
	#======Methods for positon======
	#---Setters
	def x
		@shape.x
	end
	
	def y
		@shape.y
	end
	
	def z
		@shape.z
	end
	
	def pos
		[x, y, z]
	end
	#---Getters
	def x= arg
		@shape.x = arg
	end
	
	def y= arg
		@shape.y = arg
	end
	
	def z= arg
		@shape.z = arg
	end
	
	def pos= arg
		x = arg[0]
		y = arg[1]
		x = arg[2]
	end
	
	#======Methods for force======
	#---Setters
	def push force#apply a force
		@shape.body.apply_force force
	end
	
	def f= vec2
		@shape.body.f = vec2
	end
	#--Getters
	def f
		@shape.body.f
	end
end
