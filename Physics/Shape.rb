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
				
				shape_array = [CP::Vec2.new(0,0), x_vec, diagonal, y_vec]
				
				#~ offset = diagonal / -2
				
				@width = width
				@height = height
				
				super(entity, body, shape_array, offset)
			end
			
			# Specify width of the shape in chipmunk units
			def width
				v1 = self.vert(BOTTOM_RIGHT_VERT) # bottom right
				v2 = self.vert(BOTTOM_LEFT_VERT) # bottom left
				
				# This value should always be positive
				v2.x - v1.x
				@width
			end
			
			# Specify height of the shape in chipmunk units
			def height
				v1 = self.vert(BOTTOM_LEFT_VERT) # bottom left
				v2 = self.vert(TOP_LEFT_VERT) # top left
				
				# Will always be positive
				(v1 - v2).length
				@height
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
end
