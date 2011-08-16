#!/usr/bin/ruby
require 'rubygems'
require 'chipmunk'

module CP
	module Shape
		class Circle
			def static?
				body.m == Float::INFINITY
			end
		end
		
		class Poly
			def each_vertex(&block)
				self.num_verts.times do |i|
					block.call self.vert(i)
				end
			end
			
			def each_vertex_with_index(&block)
				self.num_verts.times do |i|
					block.call self.vert(i), i
				end
			end
			
			def each_vertex_absolute(&block)
				self.num_verts.times do |i|
					block.call self.body.local2world(self.vert(i))
				end
			end
			
			def each_vertex_absolute_with_index(&block)
				self.num_verts.times do |i|
					block.call self.body.local2world(self.vert(i)), i
				end
			end
			
			def staticness
				if body.m == Float::INFINITY
					return :static
				else
					return :nonstatic
				end
			end
			
			def static?
				body.m == Float::INFINITY
			end
		end

		class Rect < CP::Shape::Poly
			attr_reader :width, :height
		
			def initialize(body, width, height, offset=CP::ZERO_VEC_2)
				@width = width
				@height = height
				
				offset =	if (offset.is_a? Symbol) && (offset == :centered)
								CP::Vec2.new -width/2.0, -height/2.0
							end
				
				shape_array = [CP::Vec2.new(0, 0),
								CP::Vec2.new(0, height),
								CP::Vec2.new(width, height),
								CP::Vec2.new(width, 0)]
				
				super body, shape_array, offset
			end
		end
		
		#~ module Polygon; class << self
			#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
			#modified to be more usable and ruby-like <- work in progress
			
			# Produces the image of a polygon.
			#~ def image(vertices)
			   #~ box_image = Magick::Image.new(EDGE_SIZE  * 2, EDGE_SIZE * 2) { self.background_color = 'transparent' }
			   #~ gc = Magick::Draw.new
			   #~ gc.stroke('red')
			   #~ gc.fill('plum')
			   #~ draw_vertices = vertices.map { |v| [v.x + EDGE_SIZE, v.y + EDGE_SIZE] }.flatten
			   #~ gc.polygon(*draw_vertices)
			   #~ gc.draw(box_image)
			   #~ return Gosu::Image.new(self, box_image, false)
			#~ end
		#~ end; end
	end
end
