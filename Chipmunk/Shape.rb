#!/usr/bin/ruby
require 'rubygems'
require 'chipmunk-ffi'

module CP
	module Shape
		class Rect < CP::Shape::Poly
			def initialize(body, center, width, height, offset=CP::Vec2.new(0,0))
				#Initially design vectors such that the object is pointing to the right (0 rad)
				#Obj. will be rotated to face the top of screen before game starts
				
				
				#Only compute the coord for the lower left corner and the upper right corner.
				#The other coordinates can be deduced based on these coords.
				
				x1,y1, x2,y2 = corners(center, height, width)

				top_left = CP::Vec2.new(x1, y2)
				top_right = CP::Vec2.new(x2, y2)
				bottom_right = CP::Vec2.new(x2, y1)
				bottom_left = CP::Vec2.new(x1, y1)
				
				shape_array =	[top_left, top_right, bottom_right, bottom_left]
				super body, shape_array, offset
			end
			
			def staticness
				if body.m == Float::INFINITY
					return :static
				else
					return :nonstatic
				end
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
					when :center
						half_width = width/2
						half_height = height/2
						x1 = -half_height
						y1 = half_width
						x2 = half_height
						y2 = -half_width
				end
				
				return x1,y1, x2,y2
			end
		end
		
		module Polygon; class << self
			#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
			#modified to be more usable and ruby-like <- work in progress
			
			# Produces the vertices of a regular polygon.
			def vertices(sides, size)
			   vertices = []
			   sides.times do |i|
				   angle = -2 * Math::PI * i / sides
				   vertices << angle.radians_to_vec2() * size
			   end
			   return vertices
			end
			
			# Produces the image of a polygon.
			def image(vertices)
			   box_image = Magick::Image.new(EDGE_SIZE  * 2, EDGE_SIZE * 2) { self.background_color = 'transparent' }
			   gc = Magick::Draw.new
			   gc.stroke('red')
			   gc.fill('plum')
			   draw_vertices = vertices.map { |v| [v.x + EDGE_SIZE, v.y + EDGE_SIZE] }.flatten
			   gc.polygon(*draw_vertices)
			   gc.draw(box_image)
			   return Gosu::Image.new(self, box_image, false)
			end
		end; end
	end
end
