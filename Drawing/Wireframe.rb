#!/usr/bin/ruby

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
				
				hash[:color] ||= :black
				
				self.fill pt[0], pt[1], :color => hash[:color]
			end
		end
	end
end

module Wireframe
	# Contains functionally common to all wireframe classes
	class WireframeObj
		def initialize(window, entity)
			@window = window
			@entity = entity
			
			@visible = true
		end
		
		def toggle_visibility
			@visible = !@visible
		end
		
		def visible?
			@visible
		end
	end

	# Draw a box in perspective
	class Box < WireframeObj
		def initialize(window, entity)
			super(window, entity)
			@window = window
			
			# Calculate the four points which comprise the bottom
			# as well as the height of the box. This will allow for
			# the construction of the box
			
			# Returns an array with references to all vertices
			# which form the polygon base
			@vertices = []
			entity.each_vertex do |v|
				vert = [v.x.to_px, v.y.to_px]
				#~ p vert
				@vertices << vert
				#~ @vertices << [v.x.to_px, v.y.to_px]
			end
			@vertices << @vertices[0]
			
			@height = entity.height(:px)
		end
		
		def update
			
		end
		
		def draw
			@vertices.each_with_index do |vertex, i|
				next_vertex = @vertices[i+1]
				break unless next_vertex
								
				# Current vertex to next vertex
				@window.draw_line	vertex[0], vertex[1], color,
									next_vertex[0], next_vertex[1], color,
									z, draw_mode
				
				# Point above current vertex to point above next vertex
				@window.draw_line	vertex[0], vertex[1] - @height, color,
									next_vertex[0], next_vertex[1] - @height, color,
									z, draw_mode
				
				# Current vertex to point above current vertex
				@window.draw_line	vertex[0], vertex[1], color,
									vertex[0], vertex[1] - @height, color,
									z, draw_mode
			end
		end
	end
	
	# Similar to box, but with a sloped top surface
	class Incline < WireframeObj
		def initialize
			# Define the height proc in such a way that (numeric - proc) 
			# and other similar mathematics functions will be defined.
		end
		
		def update
			
		end
		
		def draw
			
		end
	end
	
	# Uses a non-perspective warped circle as a base
	class Cylinder < WireframeObj
		def initialize
			
		end
		
		def update
			
		end
		
		def draw
			
		end
	end
	
	# Line Box, but the base can be any polygon
	class Prism < WireframeObj
		def initialize
			
		end
		
		def update
			
		end
		
		def draw
			
		end
	end
	
	# The prism variant of Incline
	class IrregularPrism < WireframeObj
		def initialize
			
		end
		
		def update
			
		end
		
		def draw
			
		end
	end

	class Building
		FRONT_EDGE = 7
		BACK_EDGE = 6
		BOTTOM_EDGE = 2
		CONSEALED_EDGE = 1
		SIDE_BUFFER = 10
		BOTTOM_BUFFER = (BOTTOM_EDGE/2.0).ceil
		
		Point = Struct.new(:x, :y)
	
		def initialize(physics, color = :black)
			@side_thickness = 4
			
			width = physics.width.to_px
			height = physics.height.to_px
			depth = physics.depth.to_px
			x = @side_thickness
			y = height + depth - BOTTOM_BUFFER
			
			points = Array.new()
			points << Point.new(x, y - height - depth)
			points << Point.new(x + width, y - height - depth)
			points << Point.new(x - @side_thickness, y - height)
			points << Point.new(x, y - height)
			points << Point.new(x + width, y - height)
			points << Point.new(x + width + @side_thickness, y - height)
			points << Point.new(x, y - depth)
			points << Point.new(x + width, y - depth)
			points << Point.new(x, y)
			points << Point.new(x + width, y)
			
			@img = TexPlay.create_blank_image $window,	width + @side_thickness*2 + SIDE_BUFFER*2, 
														height + depth + BOTTOM_BUFFER
			#~ @img.paint do
				#Top side, left edge
				@img.triangle	points[0].x, points[0].y, 
							points[2].x, points[2].y, 
							points[3].x, points[3].y, :color => color, :fill => true
				#Top side, right edge
				@img.triangle	points[1].x, points[1].y, 
							points[4].x, points[4].y, 
							points[5].x, points[5].y, :color => color, :fill => true
				#Front side, left edge
				@img.triangle	points[2].x, points[2].y, 
							points[3].x, points[3].y, 
							points[8].x, points[8].y, :color => color, :fill => true
				#Front side, left edge
				@img.triangle	points[4].x, points[4].y, 
							points[5].x, points[5].y, 
							points[9].x, points[9].y, :color => color, :fill => true
				#Top side, back edge
				@img.line 	points[0].x, points[0].y,
						points[1].x, points[1].y, :color => color, :thickness => BACK_EDGE
				#Top side, front edge
				@img.line	points[2].x, points[2].y,
						points[5].x, points[5].y, :color => color, :thickness => FRONT_EDGE
				#Concealed edge
				@img.line	points[6].x, points[6].y,
						points[7].x, points[7].y, :color => color, :thickness => CONSEALED_EDGE
				#Front side, bottom edge
				@img.line	points[8].x, points[8].y,
						points[9].x, points[9].y, :color => color, :thickness => BOTTOM_EDGE
			#~ end
			
			@x_offset = (-@side_thickness - 10 + SIDE_BUFFER).to_meters
			@y_offset = @img.height.to_meters + physics.pz
		end
		
		def update
			
		end
		
		def draw(physics)
			@img.draw physics.px + @x_offset, physics.py - @y_offset, physics.pz
		end
		
		def draw_line x1,y1, x2,y2, color=Gosu::Color::BLACK, thickness=1, z=0
			if thickness == 1
				$window.draw_line x1,y1, color, x2,y2, color, z
			else
				offset = thickness/2.0
				$window.draw_quad x1,y1-offset, color, x2,y2-offset, color,
								x1,y1+offset, color, x2,y2+offset, color, z
			end
		end
	end
end
