#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

require 'require_all'

#~ require_all './UI/Widgets'

class UI_State < InterfaceState
	def initialize(window, space, layers, name, open, close, player)
		super(window, space, layers, name, open, close)
		@player = player
		@font = Gosu::Font.new @window, "Century Gothic Bold", 25
		
		@left_gear = Gosu::Image.new window, "./Development/Interface/HUD_gear.png", false
		@top_gear = Gosu::Image.new window, "./Development/Interface/HUD_topgear.png", false
	end
	
	def update
		super
	end
	
	def draw
		# ========= Exp bar ========= 
		# Draw across top of screen
		corner = [0,0]
		width = @window.width
		height = 7
		color = Gosu::Color::GREEN
		
		@window.draw_quad	corner[0],corner[1], color,
							corner[0]+width,corner[1], color,
							corner[0],corner[1]+height, color,
							corner[0]+width,corner[1]+height, color
		
		# Draw tickmarks every 10%
		color = Gosu::Color::RED
		interval = width / 10
		10.times do |i|
			@window.draw_line	corner[0] + i*interval, corner[1], color,
								corner[0] + i*interval, corner[1]+height+1, color
		end
		
		# ========= Chat Box ========= 
		# Aligned to bottom-left
		height = 80
		width = 200
		corner = [0, @window.height - height]
		chat_corner = corner.clone
		chat_width = width
		
		alpha = (0.10 * 255).to_i
		color = Gosu::Color.argb alpha, 255, 255, 255
		
		@window.draw_quad	corner[0],corner[1], color,
							corner[0]+width,corner[1], color,
							corner[0],corner[1]+height, color,
							corner[0]+width,corner[1]+height, color
							
		margin = 10
		chat_margin = margin
		
		
		# ====================== NEW UI ======================
		scale_side_gears = 0.25
		side_gear_offset_x = 55
		side_gear_offset_y = 45+40
		
		draw_mana_indicator side_gear_offset_x, side_gear_offset_y, scale_side_gears
		draw_health_indicator side_gear_offset_x, side_gear_offset_y, scale_side_gears
		draw_flux_indicator
		
		
		
		
		weapon_offset_y = 30 # offset from top of screen
		weapon_offset_x = 20
		scale_weapons = 0.4
		# Left Weapon?
		x = weapon_offset_x
		y = weapon_offset_y
		z = 100
		@left_gear.old_draw	x, y, z, scale_weapons, scale_weapons
		
		# Right Weapon?
		x = @window.width - weapon_offset_x
		y = weapon_offset_y
		z = 100
		@left_gear.old_draw	x, y, z, -scale_weapons, scale_weapons
		
		# ======================
		
		
		
		#~ # === Accumulator for bottom bar widths ===
		#~ total_width = 0
		#~ 
		#~ # ========= HP Bar ========= 
		#~ # Aligned to chat box
		#~ 
		#~ corner = corner
		#~ corner[0] += width + margin
		#~ height = 20
		#~ width = 300
		#~ 
		#~ color = Gosu::Color::RED
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
							#~ 
		#~ # Draw text on bar
		#~ padding = 5
		#~ text_corner = corner
		#~ text_corner[0] += padding
		#~ 
		#~ z = 10
		#~ @font.draw "#{@player.hp} / #{@player.max_hp}", text_corner[0], text_corner[1], z
		#~ 
							#~ 
		#~ margin = 10
		#~ 
		#~ total_width += width + margin
		#~ 
		#~ # ========= MP Bar ========= 
		#~ # Same size as HP Bar
		#~ corner = corner
		#~ corner[0] += width + margin
		#~ height = 20
		#~ width = 300
		#~ 
		#~ color = Gosu::Color::BLUE
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
		#~ 
		#~ # Draw text on bar
		#~ padding = 5
		#~ text_corner = corner
		#~ text_corner[0] += padding
		#~ 
		#~ z = 10
		#~ @font.draw "#{@player.hp} / #{@player.max_hp}", text_corner[0], text_corner[1], z
		#~ 
		#~ total_width += width
		#~ 
		#~ # === Set values common to all three icons
		#~ between_buffer = 10
		#~ bottom_margin = 5
		#~ width = total_width / 3 - between_buffer / 2
		#~ height = 50
		#~ alpha = (0.8 * 255).to_i
		#~ # ========= Magic Icon =========
		#~ # align to chat
		#~ corner = chat_corner
		#~ puts "#{corner}   #{chat_corner}"
		#~ corner[0] += chat_margin + chat_width
		#~ corner [1] = @window.height - height - bottom_margin
		#~ 
		#~ color_code = [255, 0, 0]
		#~ color = Gosu::Color.argb alpha, *color_code
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
		#~ 
		#~ # ========= Left Hand Icon =========
		#~ corner = corner
		#~ corner[0] += between_buffer + width
		#~ 
		#~ color_code = [0, 255, 0]
		#~ color = Gosu::Color.argb alpha, *color_code
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
		#~ 
		#~ # ========= Right Hand Icon ========= 
		#~ corner = corner
		#~ corner[0] += between_buffer + width
		#~ 
		#~ color_code = [0, 0, 255]
		#~ color = Gosu::Color.argb alpha, *color_code
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
		#~ 
		#~ 
		#~ # ========= Menu Icon ========= 
		#~ width = 30
		#~ height = 30
		#~ bottom_margin = 10
		#~ right_margin = 10
		#~ corner = [@window.width - width - right_margin, @window.height - height - bottom_margin]
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
		
		#~ draw_old_UI
	end
	
	def finalize
		super
	end
	
	private
	
	def draw_mana_indicator(side_gear_offset_x, side_gear_offset_y, scale_side_gears)
		# Mana
		# Mana Orb
		x = (@window.width/2 - @top_gear.width/2*scale_side_gears)-side_gear_offset_x
		y = @window.height - side_gear_offset_y
		z = 100
		@left_gear.old_draw	x, y, z, scale_side_gears, scale_side_gears
		# Mana label
		heath_label_offset_x = 90
		x = (@window.width/2 - @top_gear.width/2*scale_side_gears)-heath_label_offset_x
		y = @window.height - 60
		z = 100
		@font.old_draw "MP", x,y,z, 1,1, Gosu::Color::RED
		# Mana level (text)
		heath_label_offset_x = 65
		x = (@window.width/2 - @top_gear.width/2*scale_side_gears)-heath_label_offset_x
		y = @window.height - 20
		z = 100
		@font.old_draw "#{@player.mp} | #{@player.max_mp}", x,y,z, 1,1, Gosu::Color::RED
	end
	
	def draw_health_indicator(side_gear_offset_x, side_gear_offset_y, scale_side_gears)
		# Health
		x = (@window.width/2 + @top_gear.width/2*scale_side_gears)+side_gear_offset_x
		y = @window.height - side_gear_offset_y
		z = 100
		@left_gear.old_draw	x, y, z, -scale_side_gears, scale_side_gears
		# Mana label
		heath_label_offset_x = 120
		x = (@window.width/2 - @top_gear.width/2*scale_side_gears)+heath_label_offset_x
		y = @window.height - 60
		z = 100
		@font.old_draw "HP", x,y,z, 1,1, Gosu::Color::RED
		# Mana level (text)
		heath_label_offset_x = 50
		x = (@window.width/2 - @top_gear.width/2*scale_side_gears)+heath_label_offset_x
		y = @window.height - 20
		z = 100
		@font.old_draw "#{@player.hp} | #{@player.max_hp}", x,y,z, 1,1, Gosu::Color::RED
	end
	
	def draw_flux_indicator
		# Flux
		scale_top_gear = 0.3
		top_gear_offset_y = 160
		@top_gear.old_draw	(@window.width/2 - @top_gear.width/2*scale_top_gear), 
							@window.height - top_gear_offset_y, 100,
							scale_top_gear, scale_top_gear
	end
	
	def draw_old_UI
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
	end
end
