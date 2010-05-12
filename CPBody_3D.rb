#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.11.2010

module CP
	class Body_3D
		attr_reader :xy, :xz
	
		def initialize(x, y, z)
			#Bounding box sizes are place holders.  Change them later.

			#Bottom Shape
			@xy = CP::Shape::Poly.new(CP::Body.new(70, 150), 
										CP::Shape::Polygon.vertices(4, 10), #10 sq units square
										CP::Vec2.new(0, 0))	#This vector is the offset
			@xy.body.p = CP::Vec2.new(x, y)
										
			#Side Shape
			@xz = CP::Shape::Poly.new(CP::Body.new(70, Float::INFINITY), #Eliminate rotation 
										CP::Shape::Polygon.vertices(4, 10),	#10 sq units square
										CP::Vec2.new(0, 0))
			@xz.body.p = CP::Vec2.new(x, z)
		end
		
		def apply_gravity
			gravity = @xz.body.m * 9.8 * -1
			@xz.body.apply_force(CP::Vec2.new(0,gravity),CP::Vec2.new(0,0))
		end
		
		def reset_forces(plane)
			if plane == :xy
				@xz.body.reset_forces
			elsif plane == :xz
				@xz.body.reset_forces
			end
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
