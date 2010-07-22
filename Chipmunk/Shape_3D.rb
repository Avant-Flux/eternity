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
			self.body.p.x
		end
		
		def y
			self.body.p.y
		end
		
		def z
			@z
		end
		
		def x= arg
			self.body.p.x = arg
		end
		
		def y= arg
			self.body.p.y = arg
		end
		
		def z= arg
			@z = arg
		end
		
		#~ #Setters and getters for velocity
		#~ def v
			#~ #Compute the magnitude of the velocity in 3D space
			#~ #Use the cross product function in chipmunk
			#~ #CROSS_PRODUCT @xy.body.v, @xz.body.v
			#~ @xy.body.v.cross(@xz.body.v)
		#~ end
	end

	module Shape
		class Rect < CP::Shape::Poly
			def initialize(body, center=:bottom, width, height, offset)
				#Initially design vectors such that the object is pointing to the right (0 rad)
				#Obj. will be rotated to face the top of screen before game starts
				
				
				#Only compute the coord for the lower left corner and the upper right corner.
				#The other coordinates can be deduced based on these coords.
				
				x1,y1, x2,y2 = corners center, height, width
				
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
				
				return x1,y1, x2,y2
			end
		end
	end

	module Shape_3D
		class Circle < CP::Shape::Circle
			include CP::Collide
			include CP::Position
			
			def initialize(space, collision, pos, radius, height,
			mass, moment, offset=CP::Vec2.new(0, 0))
				super CP::Body.new(mass, moment), radius, offset
				
				@space = space
				@height = height
				collision_type = collision
				
				self.body.a = (3*Math::PI/2.0)
				self.body.p = CP::Vec2.new(pos[0], pos[1])
				@z = pos[2]
			end
		end
		
		class Rect < CP::Shape::Rect
			include CP::Collide
			include CP::Position
		
			def initialize(space, collision, pos, center, width, depth, height, 
			mass, moment, offset=CP::Vec2.new(0, 0))
				super CP::Body.new(mass, moment), center, width, depth, offset
				
				@space = space
				@height = height
				collision_type = collision
				
				self.body.a = (3*Math::PI/2.0)
				self.body.p = CP::Vec2.new(pos[0], pos[1])
				@z = pos[2]
			end
		end
	end
end

#~ space = CP::Space.new
#~ 
#~ CP::Shape_3D::Circle.new(space, :collide, [0,0,0], 200, 120, 20, 50)
#~ CP::Shape_3D::Rect.new(space, :collide, [0,0,0], :bottom, 100, 100, 500, 500, 20)
