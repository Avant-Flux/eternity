#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

class UV_Map
	def initialize
		
	end
	
	def uv_map
		# Top
		@window.draw_quad	@vertices[0][0], @vertices[0][1] - @height, @color,
							@vertices[1][0], @vertices[1][1] - @height, @color,
							@vertices[2][0], @vertices[2][1] - @height, @color,
							@vertices[3][0], @vertices[3][1] - @height, @color,
							1
		
		# Left
			# Same as right, but shifted by X_Hat in the amount of width.
			# OR can use the other two vertices
		
		
		# Right
		@window.draw_quad	@vertices[1][0], @vertices[1][1], @color,
							@vertices[2][0], @vertices[2][1], @color,
							@vertices[2][0], @vertices[2][1] - @height, @color,
							@vertices[1][0], @vertices[1][1] - @height, @color,
							1
		
		# Front
		@window.draw_quad	@vertices[0][0], @vertices[0][1], @color,
							@vertices[1][0], @vertices[1][1], @color,
							@vertices[1][0], @vertices[1][1] - @height, @color,
							@vertices[0][0], @vertices[0][1] - @height, @color,
							1
		# Back
			# Same as front, but shifted by Y_HAT in the amount of depth
			# OR could use the other two vertices
	end
	
	# Create a Gosu::Image instance to contain one side represented in the UV map
	def uv_texture_image(window)
		top = left = Float::INFINITY
		bottom = right = -Float::INFINITY
		
		@vertices.each do |v|
			left = v[0]		if v[0] < left
			right = v[0]	if v[0] > right
			bottom = v[1]	if v[1] < bottom
			right = v[1]	if v[1] > right
		end
		
		width = right - left
		height = bottom - top
		
		image = TexPlay.create_blank_image window, width, height
	end
end
