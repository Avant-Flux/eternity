#!/usr/bin/ruby
 
module PhysicalProperties
	#Assume only that the class this is mixed-in to has the variable @shape defined
	#	@shape is some class in CP::Shape_3D
	#Assume also that there is a variable @animations which holds the 
	
	#======Methods for dimention======
	#Setters
		#None - these properties can not be dynamically changed
	#Getters
	def height units=:px
		case units
			when :px
				@animation.height
			when :meters
				@animation.height.to_meters
		end
	end
	
	def width units=:px
		case units
			when :px
				@animation.width
			when :meters
				@animation.width.to_meters
		end
	end
	
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
	
	def p
		@shape.body.p
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
	
	def p= arg
		@shape.body.p = arg
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
