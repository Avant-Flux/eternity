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
			
			@visible = true
			
			# Returns an array with references to all vertices
			# which form the polygon base
			@vertices = []
			# Currently using local coordinates.
			# Make sure to use world coordinates instead
			entity.each_vertex_absolute do |v|
				vert = [v.x, v.y]
				@vertices << vert
			end
			@vertices << @vertices[0]
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
			
			# Calculate the four points which comprise the bottom
			# as well as the height of the box. This will allow for
			# the construction of the box
			
			@height = entity.height(:meters)
			@color = Gosu::Color::WHITE
		end
		
		def update
			
		end
		
		def draw(zoom)
			@vertices.each_with_index do |vertex, i|
				next_vertex = @vertices[i+1]
				break unless next_vertex
				
				z = 1
								
				# Current vertex to next vertex
				@window.draw_line	vertex[0], vertex[1], @color,
									next_vertex[0], next_vertex[1], @color,
									z, :default, zoom
				
				# Point above current vertex to point above next vertex
				@window.draw_line	vertex[0], vertex[1] - @height, @color,
									next_vertex[0], next_vertex[1] - @height, @color,
									z, :default, zoom
				
				# Current vertex to point above current vertex
				@window.draw_line	vertex[0], vertex[1], @color,
									vertex[0], vertex[1] - @height, @color,
									z, :default, zoom
			end
		end
	end
	
	# Similar to box, but with a sloped top surface
	class Incline < WireframeObj
		def initialize(window, entity)
			super(window, entity)
			
			# Define the height proc in such a way that (numeric - proc) 
			# and other similar mathematics functions will be defined.
			@height = Array.new 4
			4.times do |i|
				# entity.height here should be a proc, which responds to an
				# index corresponding to a vertex
				@height[i] = entity.height(:meters)[i]
			end
			
			@color = Gosu::Color::WHITE
		end
		
		def update
			
		end
		
		def draw
			# Current vertex to next vertex
				@window.draw_line	vertex[0], vertex[1], @color,
									next_vertex[0], next_vertex[1], @color,
									z, :default, zoom
				
				# Point above current vertex to point above next vertex
				@window.draw_line	vertex[0], vertex[1] - @height, @color,
									next_vertex[0], next_vertex[1] - @height, @color,
									z, :default, zoom
				
				# Current vertex to point above current vertex
				@window.draw_line	vertex[0], vertex[1], @color,
									vertex[0], vertex[1] - @height, @color,
									z, :default, zoom
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
end
