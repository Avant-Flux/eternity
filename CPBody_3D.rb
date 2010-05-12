#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.11.2010

module CP
	class Body_3D
		def initialize
			#Bounding box sizes are place holders.  Change them later.
			@xy = CP::Shape::Poly.new(CP::Body.new(10, 150), 
										CP::Shape::Polygon.vertices(4, 10), #10 sq units square
										CP::Vec2.new(x, y))
			@xz = CP::Shape::Poly.new(CP::Body.new(10, 150), 
										CP::Shape::Polygon.vertices(4, 10),	#10 sq units square
										CP::Vec2.new(x, z))
		end
		
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
	end
end
