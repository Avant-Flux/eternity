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
		
		def draw(zoom, pos=nil)
			#Pos is actually the player object,
			# it was supposed to just be the position vector,
			# but I wanted to consolidate the code for vector projection into one place
			
			# Modulate transparency by delta_y from the "center" where the player is
			center_y = pos.py_
			
			# colors = yellow, red, blue, green
			# positions: front, right, back, left
			# index:	0 		1 		2		3
			transparency = 0x2c
			#~ transparency = 0xff
			
			transparencies = Array.new 4
			4.times do |i|
				transparencies[i] = transparency
				
				#~ # Factor should be a percent between 0 and 1
				#~ factor =	if center_y -1.5  <= @entity.py_ #If it's further back into the screen
								#~ 1
							#~ else
								#~ distance =  center_y - @entity.py_
								#~ 
								#~ 1/(distance**2)
							#~ end
				#~ 
				#~ transparencies[i] *= factor
				#~ 
				#~ transparencies[i] = transparencies[i].to_i
			end
			
			quad_colors = [0xffee44, 0xff0011, 0x2244ff, 0x116622]
			4.times do |i|
				quad_colors[i] = (transparencies[i] << 24) | quad_colors[i]
			end
			
			#~ quad_z =	[
						#~ -@entity.py_ + @entity.pz + @entity.depth(:meters)*0.10,
						#~ -@entity.py_ + @entity.pz + @entity.depth(:meters)*0.10,
						#~ -@entity.py_ + @entity.pz - @entity.depth(:meters),
						#~ -@entity.py_ + @entity.pz - @entity.depth(:meters)
						#~ ]
			
			#~ quad_z =	[@entity.pz-@entity.depth(:meters)*0.1, 
						#~ @entity.pz-@entity.depth(:meters)*0.5, 
						#~ @entity.pz-@entity.depth(:meters)*0.9, 
						#~ @entity.pz-@entity.depth(:meters)*0.5]
			
			@vertices.each_with_index do |vertex, i|
				next_vertex = @vertices[i+1]
				break unless next_vertex
				
				# Current vertex to next vertex
				@window.draw_line	vertex[0], vertex[1]-@entity.pz, @color,
									next_vertex[0], next_vertex[1]-@entity.pz, @color,
									@entity.pz, :default, zoom
				
				# Point above current vertex to point above next vertex
				@window.draw_line	vertex[0], vertex[1] - @height-@entity.pz, @color,
									next_vertex[0], next_vertex[1] - @height-@entity.pz, @color,
									@entity.pz, :default, zoom
				
				# Current vertex to point above current vertex
				@window.draw_line	vertex[0], vertex[1]-@entity.pz, @color,
									vertex[0], vertex[1] - @height-@entity.pz, @color,
									@entity.pz, :default, zoom
									
				# Quad for the side defined by these lines
				#~ @window.draw_quad vertex[0], vertex[1]-@entity.pz, quad_colors[i],
								#~ next_vertex[0], next_vertex[1]-@entity.pz, quad_colors[i],
								#~ vertex[0], vertex[1] - @height-@entity.pz, quad_colors[i],
								#~ next_vertex[0], next_vertex[1] - @height-@entity.pz, quad_colors[i],
									#~ quad_z[i], :default, zoom
			end
			
			
			# Draw the sides from back to front, so the same z index can be used 4 times
			# Back, Left, Right, Front
			z = @entity.py_ + @entity.px
			[2, 3, 1, 0].each do |i|
				vertex = @vertices[i]
				next_vertex = @vertices[i+1]
				next unless next_vertex
				@window.draw_quad vertex[0], vertex[1]-@entity.pz, quad_colors[i],
								next_vertex[0], next_vertex[1]-@entity.pz, quad_colors[i],
								vertex[0], vertex[1] - @height-@entity.pz, quad_colors[i],
								next_vertex[0], next_vertex[1] - @height-@entity.pz, quad_colors[i],
									z, :default, zoom
			end
			
			
			# Quad for the top side of the box
			color = 0xccffffff
			#~ color = (transparencies[0] << 24) | color
			#~ z = @entity.pz+@entity.py_+@entity.height(:meters)
			
			@window.draw_quad	@vertices[0][0], @vertices[0][1]-@height-@entity.pz, color,
								@vertices[1][0], @vertices[1][1]-@height-@entity.pz, color,
								@vertices[2][0], @vertices[2][1]-@height-@entity.pz, color,
								@vertices[3][0], @vertices[3][1]-@height-@entity.pz, color,
								z, :default, zoom
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
