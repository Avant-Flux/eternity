#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.11.2010

module CP
	class Body_3D
		attr_reader :xy, :xz
	
		def initialize(x, y, z)
			#Bounding box sizes are place holders.  Change them later.
			
			#Top shape
			@xy = CP::Shape::Poly.new(CP::Body.new(10, 150), 
										CP::Shape::Polygon.vertices(4, 10), #10 sq units square
										CP::Vec2.new(x, y))
										
			#Bottom shape
			@xz = CP::Shape::Poly.new(CP::Body.new(10, 150), 
										CP::Shape::Polygon.vertices(4, 10),	#10 sq units square
										CP::Vec2.new(x, z))
		end
		
		#Setters and getters should be changed to use aliases
		#Setters and Getters for Position
		def x
			@xy.body.p.x
		end
		
		def y
			@xy.body.p.y
		end
		
		def z
			@xz.body.p.y
		end
		
		def x= arg
			@xy.body.p.x = arg
			@xz.body.p.x = arg
		end
		
		def y= arg
			@xy.body.p.y = arg
		end
		
		def z= arg
			@xz.body.p.y = arg
		end
		
		#Setters and getters for velocity
		def v
			#Compute the magnitude of the velocity in 3D space
			#Use the cross product function in chipmunk
			#CROSS_PRODUCT @xy.body.v, @xz.body.v
		end
		
		def vx
			@xy.body.v.x
		end
		
		def vy
			@xy.body.v.y
		end
		
		def vz
			@xz.body.v.y
		end
		
		def vx= arg
			@xy.body.v.x = arg
		end
		
		def vy= arg
			@xy.body.v.y = arg
		end
		
		def vz= arg
			@xz.body.v.y = arg
		end
	end
end
