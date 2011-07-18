#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

class UV_Map
	TOP = 0
	LEFT = 1
	RIGHT = 2
	FRONT = 3
	BACK = 4
	
	def initialize(window, vertices, height)
		sides = Array.new 5
		sides[TOP] = [vertices]
		sides[LEFT] = []
		sides[RIGHT] = []
		sides[FRONT] = []
		sides[BACK] = []
		
		if height.is_a? Proc
			
		elsif # Assume some sort of numeric data type
			sides[TOP].each_with_index do |vert, i|
				sides[TOP][i] = vert[1] - height
			end
			
			# Y coordinates of third and fourth vertices
			sides[RIGHT][2][1] += height
			sides[RIGHT][3][1] += height
			
			# Y coordinates of third and fourth vertices
			sides[FRONT][2][1] += height
			sides[FRONT][3][1] += height
		end
		
		uvs = Array.new 5
		uvs.each_with_index do |vert,i|
			
		end
		
		uvs[TOP] = texture_image(window, vertices).draw_uv(sides[TOP])
		uvs[LEFT] = texture_image(window, vertices).draw_uv(vertices)
		uvs[RIGHT] = texture_image(window, vertices).draw_uv(vertices)
		uvs[FRONT] = texture_image(window, vertices).draw_uv(vertices)
		uvs[BACK] = texture_image(window, vertices).draw_uv(vertices)
		
		
		#~ # Top
		#~ @window.draw_quad	@vertices[0][0], @vertices[0][1] - @height, @color,
							#~ @vertices[1][0], @vertices[1][1] - @height, @color,
							#~ @vertices[2][0], @vertices[2][1] - @height, @color,
							#~ @vertices[3][0], @vertices[3][1] - @height, @color,
							#~ 1
		#~ 
		#~ # Left
			#~ # Same as right, but shifted by X_Hat in the amount of width.
			#~ # OR can use the other two vertices
		#~ 
		#~ 
		#~ # Right
		#~ @window.draw_quad	@vertices[1][0], @vertices[1][1], @color,
							#~ @vertices[2][0], @vertices[2][1], @color,
							#~ @vertices[2][0], @vertices[2][1] - @height, @color,
							#~ @vertices[1][0], @vertices[1][1] - @height, @color,
							#~ 1
		#~ 
		#~ # Front
		#~ @window.draw_quad	@vertices[0][0], @vertices[0][1], @color,
							#~ @vertices[1][0], @vertices[1][1], @color,
							#~ @vertices[1][0], @vertices[1][1] - @height, @color,
							#~ @vertices[0][0], @vertices[0][1] - @height, @color,
							#~ 1
		#~ # Back
			#~ # Same as front, but shifted by Y_HAT in the amount of depth
			#~ # OR could use the other two vertices
	end
	
	def dump(filename)
		file = pack uvs
	end
	
	def load(filename)
		
	end
	
	private
	
	# Create a Gosu::Image instance to contain one side represented in the UV map
	def texture_image(window)
		top = left = Float::INFINITY
		bottom = right = -Float::INFINITY
		
		vertices.each do |v|
			left = v[0]		if v[0] < left
			right = v[0]	if v[0] > right
			bottom = v[1]	if v[1] < bottom
			right = v[1]	if v[1] > right
		end
		
		width = right - left
		height = bottom - top
		
		TexPlay.create_blank_image window, width, height
	end
	
	def draw_uv
		
	end
	
	# Condense all UVs into one file
	def pack(uvs)
		
	end
end
