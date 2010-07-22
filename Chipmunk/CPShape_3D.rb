#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.21.2010

#~ Notes:
#~ Should contain one CP::Shape and a z coordinate, as well as other z related attributes 
require 'rubygems'
require 'chipmunk'

#Allows collision functions to be defined from within the shape
module CP
	module Collide
		def collision_fx(type1, type2=self, &block)
			@space.add_collision_func(type1, type2) do |shape1, shape2|
				yield shape1, shape2
			end
		end
	end
	
	module Position #Have setters and getters for position and velocity
		def x
		end
		
		def y
		end
		
		def z
		end
	end

	module Shape
		class Rect < CP::Shape::Poly
			def initialize(body, center=:bottom, width, height, offset)
				#Initially design vectors such that the object is pointing to the right (0 rad)
				#Obj. will be rotated to face the top of screen before game starts
				
				
				#Only compute the coord for the lower left corner and the upper right corner.
				#The other coordinates can be deduced based on these coords.
				
				x1,y1, x2,y2 = corners center
				
				top_left = CP::Vec2.new(x1, y2)
				top_right = CP::Vec2.new(x2, y2)
				bottom_left = CP::Vec2.new(x1, y1)
				bottom_right = CP::Vec2.new(x2, y1)
				
				shape_array =	[top_left, top_right, bottom_right, bottom_left]
				super body, shape_array, offset
			end
			
			private 
			
			#Given the position of the center point, and the lengths of the sides,
			#	compute the coordinates of the lower-left corner and the upper-right corner
			def corners(center, height, width)
				case center
					when :bottom
						x1 = 0
						y1 = -(width/2)
						x2 = height
						y2 = width/2
					when :top
						x1 = 0
						y1 = -(width/2)
						x2 = -height
						y2 = width/2
					when :left
						x1 = -(height/2)
						y1 = 0
						x2 = height/2
						y2 = width
					when :right
						x1 = -(height/2)
						y1 = 0
						x2 = height/2
						y2 = -width
					when :top_left
						x1 = 0
						y1 = 0
						x2 = -height
						y2 = width
					when :top_right
						x1 = 0
						y1 = 0
						x2 = -height
						y2 = -width
					when :bottom_left
						x1 = 0
						y1 = 0
						x2 = height
						y2 = width
					when :bottom_right
						x1 = 0
						y1 = 0
						x2 = height
						y2 = -width
				end
			end
		end
	end

	module Shape_3D
		class Circle < CP::Shape::Circle
			include CP::Collide
			include CP::Position
			
			def initialize(space, collision, mass, moment, radius, offset)
				@space = space
				collision_type = collision
				
				body = CP::Body.new mass, moment
				super body, radius, offset
				self.body.a = (3*Math::PI/2.0)
				#~ CP::Shape::Circle.new(CP::Body.new(mass, moment), half_width, CP::Vec2.new(0, 0))
			end
		end
		
		class Rect < CP::Shape::Rect
			include CP::Collide
			include CP::Position
		
			def initialize(space, center, width, height, mass, moment, offset)
				@space = space
				collision_type = collision
				
				body = CP::Body.new(mass, moment)
				super body, center, width, height, offset
				self.body.a = (3*Math::PI/2.0)
				#~ super body, shape_array, CP::Vec2.new(0, 0)#This vector is the offset
			end
		end
	end
	

	#~ class Shape_3D
		#~ #Setters and getters should be changed to use aliases
		#~ #Setters and Getters for Position
		#~ def x
			#~ @xy.body.p.x
		#~ end
		#~ 
		#~ def y
			#~ @xy.body.p.y
		#~ end
		#~ 
		#~ def z
			#~ @xz.body.p.y
		#~ end
		#~ 
		#~ def x= arg
			#~ @xy.body.p.x = arg
			#~ @xz.body.p.x = arg
		#~ end
		#~ 
		#~ def y= arg
			#~ @xy.body.p.y = arg
		#~ end
		#~ 
		#~ def z= arg
			#~ @xz.body.p.y = arg
		#~ end
		#~ 
		#~ #Setters and getters for velocity
		#~ def v
			#~ #Compute the magnitude of the velocity in 3D space
			#~ #Use the cross product function in chipmunk
			#~ #CROSS_PRODUCT @xy.body.v, @xz.body.v
			#~ @xy.body.v.cross(@xz.body.v)
		#~ end
		#~ 
		#~ def vx
			#~ @xy.body.v.x
		#~ end
		#~ 
		#~ def vy
			#~ @xy.body.v.y
		#~ end
		#~ 
		#~ def vz
			#~ @xz.body.v.y
		#~ end
		#~ 
		#~ def vxy
			#~ @xy.body.v
		#~ end
		#~ 
		#~ def vxz
			#~ @xz.body.v
		#~ end
		#~ 
		#~ def vx= arg
			#~ @xy.body.v.x = arg
		#~ end
		#~ 
		#~ def vy= arg
			#~ @xy.body.v.y = arg
		#~ end
		#~ 
		#~ def vz= arg
			#~ @xz.body.v.y = arg
		#~ end
		#~ 
		#~ def vxy= arg
			#~ @xy.body.v = arg
		#~ end
		#~ 
		#~ def vxz= arg
			#~ @xz.body.v = arg
		#~ end
		#~ 
		#~ #Setters and getters for angle
		#~ def a
			#~ @xy.body.a
		#~ end
		#~ 
		#~ def a= arg
			#~ @xy.body.a = arg
		#~ end
end


CP::Shape_3D::Circle.new(CP::Space.new, :collide, 120, 20, 50, CP::Vec2.new(0,0))
