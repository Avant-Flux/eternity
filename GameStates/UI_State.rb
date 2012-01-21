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
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
		
		@left_gear = Gosu::Image.new window, "./Development/Interface/HUD_gear.png", false
		@top_gear = Gosu::Image.new window, "./Development/Interface/HUD_topgear.png", false
		
		scale_side_gears = 0.25
		heath_label_offset_x = 35
		x = (@window.width/2 - @top_gear.width/2*scale_side_gears)+heath_label_offset_x
		y = @window.height - 20
		@hp_numerical_display = Widget::Label.new window, x,y,
								:width => 100, :height => @font.height,
								#~ :background_color => Gosu::Color::FUCHSIA,
								:text => "", :font => @font, :color => Gosu::Color::RED,
								:text_align => :center, :vertical_align => :top
		
		heath_label_offset_x = 80
		x = (@window.width/2 - @top_gear.width/2*scale_side_gears)-heath_label_offset_x
		y = @window.height - 20
		z = 100
		@mp_numerical_display = Widget::Label.new window, x,y,
								:width => 100, :height => @font.height,
								#~ :background_color => Gosu::Color::FUCHSIA,
								:text => "", :font => @font, :color => Gosu::Color::RED,
								:text_align => :center, :vertical_align => :top
	end
	
	def update
		super
		
		# Optimize: only reset text when hp/mp values change
		@hp_numerical_display.text = "#{@player.hp} | #{@player.max_hp}"
		@mp_numerical_display.text = "#{@player.mp} | #{@player.max_mp}"
	end
	
	def draw
		#~ # ========= Exp bar ========= 
		#~ # Draw across top of screen
		#~ corner = [0,0]
		#~ width = @window.width
		#~ height = 7
		#~ color = Gosu::Color::GREEN
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
		#~ 
		#~ # Draw tickmarks every 10%
		#~ color = Gosu::Color::RED
		#~ interval = width / 10
		#~ 10.times do |i|
			#~ @window.draw_line	corner[0] + i*interval, corner[1], color,
								#~ corner[0] + i*interval, corner[1]+height+1, color
		#~ end
		
		#~ # ========= Chat Box ========= 
		#~ # Aligned to bottom-left
		#~ height = 80
		#~ width = 200
		#~ corner = [0, @window.height - height]
		#~ chat_corner = corner.clone
		#~ chat_width = width
		#~ 
		#~ alpha = (0.10 * 255).to_i
		#~ color = Gosu::Color.argb alpha, 255, 255, 255
		#~ 
		#~ @window.draw_quad	corner[0],corner[1], color,
							#~ corner[0]+width,corner[1], color,
							#~ corner[0],corner[1]+height, color,
							#~ corner[0]+width,corner[1]+height, color
							#~ 
		#~ margin = 10
		#~ chat_margin = margin
		
		
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
		
		draw_left_weapon_indicator weapon_offset_x, weapon_offset_y, scale_weapons
		draw_right_weapon_indicator weapon_offset_x, weapon_offset_y, scale_weapons		
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
		@mp_numerical_display.draw
		#~ heath_label_offset_x = 65
		#~ x = (@window.width/2 - @top_gear.width/2*scale_side_gears)-heath_label_offset_x
		#~ y = @window.height - 20
		#~ z = 100
		#~ @font.old_draw "#{@player.mp} | #{@player.max_mp}", x,y,z, 1,1, Gosu::Color::RED
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
		# Health level (text)
		@hp_numerical_display.draw
	end
	
	def draw_flux_indicator
		# Flux
		scale_top_gear = 0.3
		top_gear_offset_y = 160
		@top_gear.old_draw	(@window.width/2 - @top_gear.width/2*scale_top_gear), 
							@window.height - top_gear_offset_y, 100,
							scale_top_gear, scale_top_gear
	end
	
	def draw_left_weapon_indicator(weapon_offset_x, weapon_offset_y, scale_weapons)
		# Left Weapon
		x = weapon_offset_x
		y = weapon_offset_y
		z = 100
		@left_gear.old_draw	x, y, z, scale_weapons, scale_weapons
	end
	
	def draw_right_weapon_indicator(weapon_offset_x, weapon_offset_y, scale_weapons)
		# Right Weapon?
		x = @window.width - weapon_offset_x
		y = weapon_offset_y
		z = 100
		@left_gear.old_draw	x, y, z, -scale_weapons, scale_weapons
	end
end
