#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

module Physics
	module Shape
		class Circle < CP::Shape::Circle
			attr_reader :gameobj
		
			def initialize(gameobj, *args)
				@gameobj = gameobj
				super(*args)
			end
		end
		
		class Rect < CP::Shape::Rect
			attr_reader :gameobj
		
			def initialize(gameobj, *args)
				@gameobj = gameobj
				super(*args)
			end
		end
		
		class Poly < CP::Shape::Poly
			attr_reader :gameobj
			
			def initialize(gameobj, *args)
				@gameobj = gameobj
				super(*args)
			end
		end
			
		class PerspRect < Physics::Shape::Poly
			BOTTOM_LEFT_VERT = 0
			BOTTOM_RIGHT_VERT = 1
			TOP_LEFT_VERT = 3
			TOP_RIGHT_VERT = 2
			
			# By design, this class calculates the width and height as needed,
			# rather than storing those values.
			def initialize(entity, body, width, height, offset=CP::Vec2::ZERO)
				x_vec = Physics::Direction::X_HAT * width
				y_vec = Physics::Direction::Y_HAT * height
				diagonal = x_vec + y_vec
				
				shape_array = [CP::Vec2::ZERO.clone, x_vec, diagonal, y_vec]
				
				offset = diagonal / 2
				shape_array.each_with_index do |vertex, i|
					shape_array[i] = vertex - offset
				end
				
				super(entity, body, shape_array, CP::Vec2::ZERO)
			end
			
			# Specify width of the shape in chipmunk units
			def width
				v1 = self.vert(0) # bottom right
				v2 = self.vert(1) # bottom left
				
				# This value should always be positive
				v1.x - v2.x
			end
			
			# Specify height of the shape in chipmunk units
			def height
				v1 = self.vert(1) # bottom left
				v2 = self.vert(2) # top left
				
				# Will always be positive
				(v1 - v2).length
			end
			
			def clone
				# Actually returns an instance of the parent class, Physics::Shape::Poly
				shape_array = []
				self.each_vertex do |v|
					shape_array << v
				end
				
				body = CP::Body.new self.body.m, self.body.i
				body.p.x = self.body.p.x
				body.p.y = self.body.p.y
				
				return(self.class.superclass.new self.gameobj, body, shape_array, CP::Vec2::ZERO)
			end
		end
	end
	
	class Body < CP::Body
		attr_reader :gameobj
		
		def initialize(gameobj, *args)
			@gameobj = gameobj
			super(*args)
		end
	end
end
