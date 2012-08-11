#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
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
		
		#~ @weapon_gear = Gosu::Image.new window,
						#~ "./Development/Interface/interface720/weapongear.png", false
		
		@level_indicator = LevelIndicator.new window, 0,0,
								:relative => window,
								:top => 10,		:bottom => :auto,
								:left => :auto,	:right => :auto,
								
								:background_color => Gosu::Color::NONE
		
		
		# --- Positioning notes
		# Flux				:	centered
		# Mana/HP			:	offset relative to Flux
		# Weapon Indicators	:	offset relative to Resource gauges
		@flux_indicator = FluxIndicator.new window, 0,0, player,
								:relative => window,
								:top => :auto,	:bottom => 120,
								:left => :auto,	:right => :auto,
								
								:z_index => 0,
								
								:background_color => Gosu::Color::NONE
		
		@mp_indicator = MP_Indicator.new window, 0,0, player,
								:relative => @flux_indicator,
								:z_index => -1,
								
								:margin_right => 100,	:margin_right_units => :percent,
								:margin_top => 100,		:margin_top_units => :percent,
								:top => -12,		:bottom => :auto,
								:left => :auto,		:right => -50,
								
								:background_color => Gosu::Color::NONE
		
		@hp_indicator = HP_Indicator.new window, 0,0, player,
								:relative => @flux_indicator,
								:z_index => -1,
								
								:margin_left => 100,	:margin_left_units => :percent,
								:margin_top => 100,		:margin_top_units => :percent,
								:top => -12,		:bottom => :auto,
								:left => -50,	:right => :auto,
								
								:background_color => Gosu::Color::NONE
		
		weapon_offset_x = 20
		weapon_offset_y = 0
		
		#~ x = @window.width/2 - weapon_offset_x - @weapon_gear.width
		z = 100
		@left_weapon = WeaponIndicator.new window, 0,0,
							:relative => @mp_indicator,
							:margin_right => 100,	:margin_right_units => :percent,
							
							:top => :auto,	:bottom => weapon_offset_y,
							:right => weapon_offset_x, :left => :auto,
							
							:z_index => -2,
							
							:background_color => Gosu::Color::NONE
		
		x = @window.width/2 + weapon_offset_x
		z = 100
		@right_weapon = WeaponIndicator.new window, 0,0,
							:relative => @hp_indicator,
							:margin_left => 100,	:margin_left_units => :percent,
							
							:top => :auto,	:bottom => weapon_offset_y,
							:right => :auto, :left => weapon_offset_x,
							
							:z_index => -2,
							
							:background_color => Gosu::Color::NONE
	end
	
	def update
		#~ super
		
		# TODO: Optimize - only reset text when values change
		@level_indicator.update(@player.level)
		
		@mp_indicator.update(@player.mp, @player.max_mp)
		@hp_indicator.update(@player.hp, @player.max_hp)
		
		#~ @left_weapon.update
		#~ @right_weapon.update
	end
	
	def draw
		@level_indicator.draw
		
		widget_resolution = 1080.0
		display_resolution = @window.height
		zoom = display_resolution / widget_resolution
		
		# NOTE: Scaling results in aliasing of text and graphics
		#~ @window.scale zoom,zoom, @window.width/2, @window.height do
			# ====================== NEW UI ======================
			@mp_indicator.draw
			@hp_indicator.draw
			@flux_indicator.draw
			
			@left_weapon.draw
			@right_weapon.draw
		#~ end
	end
end
