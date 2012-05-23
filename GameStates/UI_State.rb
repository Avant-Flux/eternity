#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

require 'require_all'

require 'gl'
require 'glu'

include Gl
include Glu

class UI_State# < InterfaceState
	def initialize(window, space, player)
		@window = window
		@space = space
		@player = player
		
		
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
		
		@mana_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/mpgear.png", false
		@health_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/hpgear.png", false
		@flux_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/fluxgear.png", false
		@level_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/levelgear.png", false
		
		@weapon_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/weapongear.png", false
		
		heath_label_offset_x = 80
		width = 50
		x = (@window.width/2)+heath_label_offset_x
		y = @window.height - 60 -20
		@hp_label = Widget::Label.new window, x,y,
					:width => width, :height => @font.height,
					#~ :background_color => Gosu::Color::GREEN,
					:text => "HP", :font => @font, :color => Gosu::Color::RED,
					:text_align => :center, :vertical_align => :top
		heath_label_offset_x = 10
		width = 100
		x = (@window.width/2) + heath_label_offset_x
		y = @window.height - 35
		@hp_numerical_display = Widget::Label.new window, x,y,
								:width => width, :height => @font.height,
								#~ :background_color => Gosu::Color::GREEN,
								:text => "", :font => @font, :color => Gosu::Color::RED,
								:text_align => :center, :vertical_align => :top
		
		heath_label_offset_x = 80
		width = 50
		x = (@window.width/2 - width)-heath_label_offset_x
		y = @window.height - 60 - 20
		@mp_label = Widget::Label.new window, x,y,
					:width => width, :height => @font.height,
					#~ :background_color => Gosu::Color::GREEN,
					:text => "MP", :font => @font, :color => Gosu::Color::RED,
					:text_align => :center, :vertical_align => :top
		heath_label_offset_x = 10
		width = 100
		x = (@window.width/2 - width) - heath_label_offset_x
		y = @window.height - 35
		z = 100
		@mp_numerical_display = Widget::Label.new window, x,y,
								:width => width, :height => @font.height,
								#~ :background_color => Gosu::Color::FUCHSIA,
								:text => "", :font => @font, :color => Gosu::Color::RED,
								:text_align => :center, :vertical_align => :top
		
		width = 50
		@level = Widget::Label.new window, (@window.width - width)/2, 25,
				:width => width, :height => @font.height,
				#~ :background_color => Gosu::Color::FUCHSIA,
				:text => "", :font => @font, :color => Gosu::Color::RED,
				:text_align => :center, :vertical_align => :bottom
		
	end
	
	def update
		#~ super
		
		# Optimize: only reset text when values change
		@level.text = "#{@player.level}"
		@hp_numerical_display.text = "#{@player.hp} | #{@player.max_hp}"
		@mp_numerical_display.text = "#{@player.mp} | #{@player.max_mp}"
	end
	
	def draw
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
		#~ side_gear_offset_x = 55
		side_gear_offset_x = 48
		side_gear_offset_y = 45+40+20
		
		draw_mana_indicator side_gear_offset_x, side_gear_offset_y, scale_side_gears
		draw_health_indicator side_gear_offset_x, side_gear_offset_y, scale_side_gears
		draw_flux_indicator
		
		draw_level_indicator
		
		weapon_offset_y = 20 # offset from top of screen
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
		x = (@window.width/2 - @mana_gear.width/2)-side_gear_offset_x
		y = @window.height - side_gear_offset_y
		z = 100
		@mana_gear.draw x, y, z 
		# Mana label
		#~ heath_label_offset_x = 90
		#~ x = (@window.width/2 - @mana_gear.width/2)-heath_label_offset_x
		#~ y = @window.height - 60 - 20
		#~ z = 100
		#~ @font.old_draw "MP", x,y,z, 1,1, Gosu::Color::RED
		@mp_label.draw
		# Mana level (text)
		@mp_numerical_display.draw
		
		#~ @window.gl z do
			#~ glBegin(GL_LINES)
				#~ glVertex2i(30,30)
				#~ glVertex2i(200,30)
			#~ glEnd()
		#~ end
	end
	
	def draw_health_indicator(side_gear_offset_x, side_gear_offset_y, scale_side_gears)
		# Health
		x = (@window.width/2 - @health_gear.width/2)+side_gear_offset_x
		y = @window.height - side_gear_offset_y
		z = 100
		@health_gear.draw x, y, z
		# Health label
		#~ heath_label_offset_x = 120
		#~ x = (@window.width/2 - @health_gear.width/2)+heath_label_offset_x
		#~ y = @window.height - 60 -20
		#~ z = 100
		#~ @font.old_draw "HP", x,y,z, 1,1, Gosu::Color::RED
		@hp_label.draw
		# Health level (text)
		@hp_numerical_display.draw
	end
	
	def draw_flux_indicator
		# Flux
		scale_top_gear = 0.3
		top_gear_offset_y = 150+20
		@flux_gear.draw	(@window.width/2 - @flux_gear.width/2),
							@window.height - top_gear_offset_y, 100
	end
	
	def draw_left_weapon_indicator(weapon_offset_x, weapon_offset_y, scale_weapons)
		# Left Weapon
		x = weapon_offset_x
		y = weapon_offset_y
		z = 100
		@weapon_gear.draw x, y, z
	end
	
	def draw_right_weapon_indicator(weapon_offset_x, weapon_offset_y, scale_weapons)
		# Right Weapon
		x = @window.width - weapon_offset_x - @weapon_gear.width
		y = weapon_offset_y
		z = 100
		@weapon_gear.draw x, y, z
	end
	
	def draw_level_indicator
		x = @window.width/2 - @level_gear.width/2
		y = 10
		z = 100
		@level_gear.draw x,y,z
		@level.draw
	end
end
