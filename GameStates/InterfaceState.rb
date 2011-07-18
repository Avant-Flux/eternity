#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

require './UI/Widgets'

class InterfaceState < GameState
	def initialize(window, space, layers, name, player)
		super(window, space, layers, name)
	end
	
	def update
		super
	end
	
	def draw
		# Stat tracking box (upper left)
		color = Gosu::Color::GREEN
		corner = [10,10]
		width = 300
		height = 100
		@window.draw_quad	corner[0],corner[1], color,
							corner[0]+width,corner[1], color,
							corner[0],corner[1]+height, color,
							corner[0]+width,corner[1]+height, color
		
		# Button layout (bottom center)
		z = 10
		button_corners = []	# All corners specified as top-left
		buttons = 3
		
		bottom_margin = 10
		between_buffer = 20
		height = 35
		width = 150
		whole_width = buttons*width + (buttons-1)*between_buffer
		left_margin = (@window.width - whole_width)/2
		
		button_corners << [left_margin, @window.height-bottom_margin-height]
		(buttons-1).times do |i|
			button_corners << button_corners[i].clone
			button_corners[i+1][0] += width+between_buffer
		end
		
		color = Gosu::Color::RED
		
		button_corners.each do |corner|
			@window.draw_quad	corner[0],corner[1], color,
								corner[0]+width,corner[1], color,
								corner[0],corner[1]+height, color,
								corner[0]+width,corner[1]+height, color, z
		end
		
		# Draw again for the buttons in the back
		z = 5 # just make sure it's less than the first z index
		offset = [10, -10]
		color2 = Gosu::Color.from_hsv color.hue, color.saturation, color.value
		color2.value = color.value - 0.3
		
		
		button_corners.each do |corner|
			corner[0] += offset[0]
			corner[1] += offset[1]
			@window.draw_quad	corner[0],corner[1], color2,
								corner[0]+width,corner[1], color2,
								corner[0],corner[1]+height, color2,
								corner[0]+width,corner[1]+height, color2, z
		end
		
		# Flux bar (goes on top of button layout)
		bottom_margin = bottom_margin + height - offset[1] + 5 # Relative to the top of the buttons
		width = whole_width #Width of the whole button layout
		height = 10
		
		corner = [left_margin, @window.height-bottom_margin-height] 
		
		color = Gosu::Color::YELLOW
		shading = Gosu::Color::YELLOW.dup
		shading.value -= 0.5
		
		@window.draw_quad	corner[0],corner[1], color,
							corner[0]+width,corner[1], shading,
							corner[0],corner[1]+height, color,
							corner[0]+width,corner[1]+height, shading
		
		
		# Weapons
		# top right
		# SC2 unit building style icons with loading bar
			# loading bar
		top_margin = 10
		right_margin = 10
		between_buffer = 10
		
		width = 50
		height = 50
		
		alpha = (0.20 * 255).to_i # 0..255  20% transparency
		color_code = [0, 255, 0] #Green
		
		color = Gosu::Color.argb alpha, *color_code
		
		button_corners = []
		button_corners << [@window.width - width - right_margin, top_margin]
		1.times do |i|
			button_corners << [@window.width - width - right_margin, top_margin + between_buffer + height]
		end
		
		button_corners.each do |corner|
			@window.draw_quad	corner[0],corner[1], color,
								corner[0]+width,corner[1], color,
								corner[0],corner[1]+height, color,
								corner[0]+width,corner[1]+height, color
		end
	end
	
	def finalize
		super
	end
end
