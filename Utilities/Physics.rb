#!/usr/bin/ruby
 
module Physics
	#This is the new structure for the chipmunk handling of the game engine
	#It should create a complete abstraction of the underlying chipmunk code.
	#It may eventually be possible to forgo usage of chipmunk-ffi at some point
	#and simply use ffi and the C library.
	class PhysicsObject
		attr_reader :bottom, :side, :render_object
	
		def initialize(bottom, side, render_object=nil)
			@bottom = bottom
			@side = side
			@render_object = render_object
				#Set render_object to be the same as the side if no render object is supplied.
				@render_object ||= side
		end
		
		def positon=(pos=[0,0,0])
			@bottom.p.x = pos[0]
			@bottom.p.y = pos[1]
			@side.p.y = pos[2]
		end
	end
	
	class Entity < PhysicsObject
		def initialize(mass, moment, pos=[0,0,0], dimentions=[1,1,1])
			#Use the supplied mass for the circle only, as the rectangle should not rotate.
			
			#Define the bottom of the Entity as a circle, and the side as a rectangle.
			#This approximates the volume as a cylinder.
			
			bottom = CP::Shape::Circle.new CP::Body.new(mass,moment), dimentions[0], CP::ZERO_VEC_2
			side = CP::Shape::Rect.new	CP::Body.new(mass,Float::INFINITY), :bottom_left,
										dimentions[0], dimentions[2]
			
			super(bottom, side)
			position = pos
		end
	end
	
	class EnvironmentObject < PhysicsObject
		def initialize(pos=[0,0,0], dimentions=[1,1,1])
			bottom =	CP::Shape::Rect.new	CP::Body.new(Float::INFINITY,Float::INFINITY), 
											:bottom_left, dimentions[0], dimentions[1]
			side =		CP::Shape::Rect.new	CP::Body.new(Float::INFINITY,Float::INFINITY), 
											:bottom_left, dimentions[0], dimentions[3]
			
			render_object = CP::Shape::Rect.new	CP::Body.new(Float::INFINITY,Float::INFINITY), 
												:bottom_left, side.width, side.height + bottom.height
			
			super(bottom, side, render_object)
			position = pos
		end
	end
end
