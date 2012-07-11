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
		
		@weapon_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/weapongear.png", false
		
		@level_indicator = LevelIndicator.new window, 0,0,
								:relative => window,
								:top => 10,		:bottom => :auto,
								:left => :auto,	:right => :auto
		
		
		# --- Positioning notes
		# Flux				:	centered
		# Mana/HP			:	offset relative to Flux
		# Weapon Indicators	:	offset relative to Resource gauges
		@flux_indicator = FluxIndicator.new window, 0,0,
								:relative => window,
								:top => :auto,	:bottom => 95,
								:left => :auto,	:right => :auto,
								
								:z_index => 0,
								
								:background_color => Gosu::Color::NONE
		
		@mana_indicator = MP_Indicator.new window, 0,0,
								:relative => @flux_indicator,
								:z_index => -1,
								
								:margin_right => 100,	:margin_right_units => :percent,
								:margin_top => 100,		:margin_top_units => :percent,
								:top => -10,		:bottom => :auto,
								:left => :auto,		:right => -16,
								
								:background_color => Gosu::Color::NONE
		
		@hp_indicator = HP_Indicator.new window, 0,0,
								:relative => @flux_indicator,
								:z_index => -1,
								
								:margin_left => 100,	:margin_left_units => :percent,
								:margin_top => 100,		:margin_top_units => :percent,
								:top => -10,		:bottom => :auto,
								:left => -16,	:right => :auto,
								
								:background_color => Gosu::Color::NONE
		
		weapon_offset_x = 90 # offset from center
		weapon_offset_y = 20 # offset from bottom of screen
		scale_weapons = 1
		
		x = @window.width/2 - weapon_offset_x - @weapon_gear.width
		z = 100
		@left_weapon = WeaponIndicator.new window, x,0,
							:relative => window,
							:top => :auto,	:bottom => weapon_offset_y,
							
							:z_index => -2,
							
							:background_color => Gosu::Color::WHITE
		
		x = @window.width/2 + weapon_offset_x
		z = 100
		@right_weapon = WeaponIndicator.new window, x,0,
							:relative => window,
							:top => :auto,	:bottom => weapon_offset_y,
							
							:z_index => -2,
							
							:background_color => Gosu::Color::WHITE
	end
	
	def update
		#~ super
		
		# TODO: Optimize - only reset text when values change
		@level_indicator.update(@player.level)
		
		@mana_indicator.update(@player.mp, @player.max_mp)
		@hp_indicator.update(@player.hp, @player.max_hp)
		
		#~ @left_weapon.update
		#~ @right_weapon.update
	end
	
	def draw
		# ====================== NEW UI ======================
		@mana_indicator.draw
		@hp_indicator.draw
		@flux_indicator.draw
		
		@level_indicator.draw
		
		
		scale_weapons = 1
		
		# TODO: !!!!! Finish implementation of WeaponIndicator !!!!!
		@left_weapon.draw scale_weapons
		
		# Right Weapon
		@right_weapon.draw scale_weapons
	end
	
	def finalize
		super
	end
end
