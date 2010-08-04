#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 08.04.2010

require 'rubygems'
require 'texplay'

module Gosu
	class Image
		def triangle(x1,y1, x2,y2, x3,y3, hash={})
			hash[:closed] = true
			self.polyline [x1,y1, x2,y2, x3,y3], hash
			
			if hash[:fill] || hash[:filled]
				midpoint = [(x2+x3)/2, (y2+y3)/2]
				pt = [(x1+midpoint[0])/2, (y1+midpoint[1])/2]
				
				unless hash[:color]
					hash[:color] = :black
				end
				
				self.fill pt[0], pt[1], hash
			end
		end
	end
end

module Wireframe
	class Circle
		def initialize
			
		end
		
		def update
			
		end
		
		def draw
			
		end
	end

	class Rect
		def initialize(window, shape)
			@window = window
			@shape = shape
			
			
			color = Gosu::Color::BLACK
			side_thickness = 10
			front_edge = 10
			back_edge = 5
			consealed_edge = 2
			z = 10
			front_offset = front_edge / 2.0
			
			scale = 1
			width = @shape.width*scale
			height = @shape.height*scale
			depth = @shape.depth*scale
			x = @shape.x*scale
			y = @shape.y*scale
			
			point = Struct.new(:x, :y)
			
			points = Array.new()
			points << point.new(x, y - height - depth)
			points << point.new(x + width, y - height - depth)
			points << point.new(x - side_thickness, y - height)
			points << point.new(x, y - height)
			points << point.new(x + width, y - height)
			points << point.new(x + width + side_thickness, y - height)
			points << point.new(x, y - depth)
			points << point.new(x + width, y - depth)
			points << point.new(x, y)
			points << point.new(x + width, y)
			
			color = :black
			
			@img = TexPlay.create_blank_image @window, @shape.width + 100, @shape.height + @shape.height
			@img.triangle points[0].x, points[0].y, 
						points[2].x, points[2].y, 
						points[3].x, points[3].y, :color => color, :fill => true
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
			#~ @img.line points[0].x, points[0].y, points[2].x, points[2].y, :color => color
		end
		
		def update
			
		end
		
		def draw
			color = Gosu::Color::BLACK
			side_thickness = 10
			front_edge = 10
			back_edge = 5
			consealed_edge = 2
			z = 10
			
			@img.draw @shape.x, @shape.y + @shape.z, @shape.z
			
			#NOTE: Need to modify the triangles slightly to compensate for the thicker front edge
				#Also, remember, up is neg-y
			
			#~ front_offset = front_edge / 2.0
			#~ 
			#~ scale = 1
			#~ width = @shape.width*scale
			#~ height = @shape.height*scale
			#~ depth = @shape.depth*scale
			#~ x = @shape.x*scale
			#~ y = @shape.y*scale
			
			#~ point = Struct.new(:x, :y)
			#~ 
			#~ points = Array.new()
			#~ 
			#~ points << point.new(x, y - height - depth)
			#~ points << point.new(x + width, y - height - depth)
			#~ points << point.new(x - side_thickness, y - height)
			#~ points << point.new(x, y - height)
			#~ points << point.new(x + width, y - height)
			#~ points << point.new(x + width + side_thickness, y - height)
			#~ points << point.new(x, y - depth)
			#~ points << point.new(x + width, y - depth)
			#~ points << point.new(x, y)
			#~ points << point.new(x + width, y)
			#~ 
			#~ @window.draw_triangle points[0].x, points[0].y, color,
								#~ points[2].x, points[2].y-front_offset, color,
								#~ points[3].x, points[3].y-front_offset, color
								#~ 
			#~ @window.draw_triangle points[1].x, points[1].y, color,
								#~ points[4].x, points[4].y-front_offset, color,
								#~ points[5].x, points[5].y-front_offset, color
								#~ 
			#~ @window.draw_triangle points[2].x, points[2].y+front_offset, color,
								#~ points[3].x, points[3].y+front_offset, color,
								#~ points[8].x, points[8].y, color
			#~ 
			#~ @window.draw_triangle points[4].x, points[4].y+front_offset, color,
								#~ points[5].x, points[5].y+front_offset, color,
								#~ points[9].x, points[9].y, color
								#~ 
			#~ @window.draw_quad(points[2].x, (points[2].y - front_offset), color,
							#~ points[5].x, (points[5].y + front_offset), color,
							#~ points[2].x, (points[2].y - front_offset), color,
							#~ points[5].x, (points[5].y + front_offset), color)
			#~ @window.draw_line points[2].x, points[2].y+front_offset, color,
							#~ points[5].x, points[5].y+front_offset, color
			
			#~ #Front side, left edge
			#~ @window.draw_triangle(@shape.x, @shape.y, color, 
									#~ @shape.x, @shape.y - @shape.height, color,
									#~ @shape.x - side_thickness, @shape.y - @shape.height, color, z)
			#~ #Front side, right edge
			#~ @window.draw_triangle(@shape.x + @shape.width, @shape.y, color, 
							#~ @shape.x + @shape.width, @shape.y - @shape.height, color,
							#~ @shape.x + @shape.width + side_thickness, @shape.y - @shape.height, color, z)
			#~ #Top side, left edge
			#~ @window.draw_triangle(@shape.x, @shape.y - @shape.height, color,
									#~ @shape.x, @shape.y - @shape.height - @shape.depth, color,
									#~ @shape.x - side_thickness, @shape.y - @shape.height, color, z)
			#~ #Top side, right edge
			#~ @window.draw_triangle(@shape.x + @shape.width, @shape.y - @shape.height, color,
							#~ @shape.x + @shape.width, @shape.y - @shape.height - @shape.depth, color,
							#~ @shape.x + @shape.width + side_thickness, @shape.y - @shape.height, color)
			#~ 
			#~ #Top side, back edge
			#~ @window.draw_line(@shape.x, @shape.y - @shape.height - @shape.depth, color,
								#~ @shape.x + @shape.width, @shape.y - @shape.height - @shape.depth, color)
			#~ #Top side, front edge, AKA front side, top edge
			#~ @window.draw_line(@shape.x, @shape.y - @shape.height, color,
								#~ @shape.x + @shape.width, @shape.y - @shape.height, color)
			#~ #Front side, bottom edge
			#~ @window.draw_line(@shape.x, @shape.y, color,
								#~ @shape.x + @shape.width, @shape.y, color)
			#~ #Back side, bottom edge
			#~ @window.draw_line(@shape.x, @shape.y - @shape.depth, color,
								#~ @shape.x + @shape.width, @shape.y - @shape.depth, color)
								
			
		end
		
		def draw_line window, x1,y1, x2,y2, color=Gosu::Color::BLACK, thickness=1, z=0
			if thickness == 1
				window.draw_line x1,y1, color, x2,y2, color, z
			else
				offset = thickness/2.0
				window.draw_quad x1,y1-offset, color, x2,y2-offset, color,
								x1,y1+offset, color, x2,y2+offset, color, z
			end
		end
	end
end
