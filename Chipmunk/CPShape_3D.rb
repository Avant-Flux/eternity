#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.21.2010

#~ Notes:
#~ Should contain one CP::Shape and a z coordinate, as well as other z related attributes 
require 'rubygems'
require 'chipmunk'

module CP
	module Shape_3D
		class Circle < CP::Shape::Circle
			def initialize(space, collision, mass, moment, radius, offset)
				@space = space
				collision_type collision
				
				body = CP::Body.new mass, moment
				super body, radius, offset
				
				#~ CP::Shape::Circle.new(CP::Body.new(mass, moment), half_width, CP::Vec2.new(0, 0))
			end
		end
		
		class Rect < CP::Shape::Rect
			def initialize(space, center, width, height, mass, moment, offset)
				@space = space
				collision_type collision
				
				body = CP::Body.new(mass, moment)
				super body, center, width, height, offset
				#~ super body, shape_array, CP::Vec2.new(0, 0)#This vector is the offset
			end
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

	#~ class Shape_3D
		#~ attr_reader :xy, :xz, :space
	#~ 
		#~ def initialize(space, x, y, z, width, height, 
		#~ xy_collision_type, xz_collision_type, mass, moment)
			#~ @width = width
			#~ @height = height
			#~ 
			#~ @space = space
			#~ 
			#~ half_width = width/2
			#~ #Bottom Shape
			#~ @xy = CP::Shape::Circle.new(CP::Body.new(mass, moment), half_width, CP::Vec2.new(0, 0))
			#~ @xy.body.p = CP::Vec2.new(x, y)
										#~ 
			#~ @xy.body.a = (3*Math::PI/2.0)
			#~ 
			#~ @xy.collision_type = xy_collision_type
		#~ end
		#~ 
		#~ def transfer_x
			#~ #Transfer the x component of force on xz to xy
			#~ #Then, copy the x component of position from xy to xz
			#~ apply_force :xy, CP::Vec2.new(f(:xz).x,0)
			#~ f(:xz).x = 0
			#~ @xz.body.p.x = @xy.body.p.x
		#~ end
		#~ 
		#~ def apply_gravity
			#~ if self.z < 0
				#~ self.z = 0
			#~ else
				#~ gravity = @xz.body.m * 9.8 * -1
				#~ apply_force(:xz, CP::Vec2.new(0, gravity), CP::Vec2.new(0,0))
			#~ end
		#~ end
		#~ 
		#~ def apply_force(plane, force_vector, relative_offset=CP::Vec2.new(0,0))
			#~ if plane == :xy
				#~ @xy.body.apply_force(force_vector, relative_offset)
			#~ elsif plane == :xz
				#~ @xz.body.apply_force(force_vector, relative_offset)
			#~ end
		#~ end
		#~ 
		#~ def reset_forces(plane)
			#~ if plane == :xy
				#~ @xy.body.reset_forces
			#~ elsif plane == :xz
				#~ @xz.body.reset_forces
			#~ elsif plane == :all
				#~ @xy.body.reset_forces
				#~ @xz.body.reset_forces
			#~ end
		#~ end
		#~ 
		#~ #Setters and getters for force
		#~ def f plane
			#~ p = if plane == :xy
				#~ @xy
			#~ elsif plane == :xz
				#~ @xz
			#~ end
			#~ 
			#~ p.body.f
		#~ end
		#~ 
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
		#~ 
		#~ private
		#~ 
		#~ def xy_collision_fx(&block)
			#~ @space.xy.add_collision_func(@xy.collision_type, @xy.collision_type) do |b1_shape, b2_shape|
				#~ yield b1_shape, b2_shape
			#~ end
		#~ end
		#~ 
		#~ def xz_collision_fx(&block)
			#~ @space.xz.add_collision_func(@xz.collision_type, @xz.collision_type) do |s1_shape, s2_shape|
				#~ yield s1_shape, s2_shape
			#~ end
		#~ end
	#~ end
	
	#~ class Entity_Body < Body_3D
		#~ def initialize(space, x, y, z, width, height, mass=100, moment=150)
			#~ super(space, x, y, z, width, height, :entity_bottom, :entity_side, mass, moment)
			#~ 
			#~ xy_collision_fx do |b1_shape, b2_shape|
				#~ if 
					#~ nil
				#~ else
					#~ nil
				#~ end
				#~ 1
			#~ end
			#~ 
			#~ xz_collision_fx do |s1_shape, s2_shape|
				#~ nil
			#~ end
		#~ end
	#~ end
	#~ 
	#~ class Building_Body < Body_3D
		#~ def initialize(space, x, y, z, width, height)
			#~ super(space, x, y, z, width, height, :building_bottom, :building_side, 
					#~ Float::INFINITY, Float::INFINITY)
			#~ 
			#~ xy_collision_fx do |b1_shape, b2_shape|
				#~ 1
			#~ end
			#~ 
			#~ xz_collision_fx do |s1_shape, s2_shape|
				#~ nil
			#~ end
		#~ end
	#~ end
end
