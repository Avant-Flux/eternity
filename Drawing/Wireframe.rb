#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 08.09.2010

require 'rubygems'
require 'texplay'

module Gosu
	class Image
		def triangle(x1,y1, x2,y2, x3,y3, hash={})
			hash[:closed] = true
			self.polyline [x1,y1, x2,y2, x3,y3], :closed => true
			
			if hash[:fill] || hash[:filled]
				midpoint = [(x2+x3)/2, (y2+y3)/2]
				pt = [(x1+midpoint[0])/2, (y1+midpoint[1])/2]
				
				unless hash[:color]
					hash[:color] = :black
				end
				
				self.fill pt[0], pt[1], :color => hash[:color]
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
		def initialize(window, shape, color = :black)
			@window = window
			@shape = shape
			
			@side_thickness = 4
			
			front_edge = 10
			back_edge = 5
			bottom_edge = 2
			consealed_edge = 2
			bottom_buffer = (bottom_edge/2.0).ceil
			
			scale = 1
			width = @shape.width*scale
			height = @shape.height*scale
			depth = @shape.depth*scale
			x = @side_thickness
			y = @shape.height + @shape.depth - bottom_buffer
			
			point = Struct.new(:x, :y)
			
			points = Array.new()
			points << point.new(x, y - height - depth)
			points << point.new(x + width, y - height - depth)
			points << point.new(x - @side_thickness, y - height)
			points << point.new(x, y - height)
			points << point.new(x + width, y - height)
			points << point.new(x + width + @side_thickness, y - height)
			points << point.new(x, y - depth)
			points << point.new(x + width, y - depth)
			points << point.new(x, y)
			points << point.new(x + width, y)
			
			@img = TexPlay.create_blank_image @window,	width + @side_thickness*2, 
														height + depth + bottom_buffer
			@img.paint do
				#Top side, left edge
				triangle	points[0].x, points[0].y, 
							points[2].x, points[2].y, 
							points[3].x, points[3].y, :color => color, :fill => true
				#Top side, right edge
				triangle	points[1].x, points[1].y, 
							points[4].x, points[4].y, 
							points[5].x, points[5].y, :color => color, :fill => true
				#Front side, left edge
				triangle	points[2].x, points[2].y, 
							points[3].x, points[3].y, 
							points[8].x, points[8].y, :color => color, :fill => true
				#Front side, left edge
				triangle	points[4].x, points[4].y, 
							points[5].x, points[5].y, 
							points[9].x, points[9].y, :color => color, :fill => true
				#Top side, back edge
				line 	points[0].x, points[0].y,
						points[1].x, points[1].y, :color => color, :thickness => back_edge
				#Top side, front edge
				line	points[2].x, points[2].y,
						points[5].x, points[5].y, :color => color, :thickness => front_edge
				#Concealed edge
				line	points[6].x, points[6].y,
						points[7].x, points[7].y, :color => color, :thickness => consealed_edge
				#Front side, bottom edge
				line	points[8].x, points[8].y,
						points[9].x, points[9].y, :color => color, :thickness => bottom_edge
			end
			
			@x = @shape.x - @side_thickness
			@y = @shape.y - @img.height - @shape.z
			@z = 10
		end
		
		def update
			
		end
		
		def draw
			@img.draw @x, @y, @z
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