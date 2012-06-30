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
		
		x = 0
		y = 0
		@level_indicator = LevelIndicator.new window, x,y
		
		x = 0
		y = 0
		@mana_indicator = MP_Indicator.new window, x, y
		
		x = 0
		y = 0
		@hp_indicator = HP_Indicator.new window, x, y
		
		x = 0
		y = 0
		@flux_indicator = FluxIndicator.new window, x,y
		
		
		
		
		
		weapon_offset_x = 90 # offset from center
		weapon_offset_y = 20 # offset from bottom of screen
		scale_weapons = 1
		
		x = @window.width/2 + weapon_offset_x
		y = @window.height - @weapon_gear.height*scale_weapons - weapon_offset_y
		z = 100
		@left_weapon = WeaponIndicator.new window, x,y
		
		#~ x = 0
		#~ y = 0
		x = @window.width/2 + weapon_offset_x
		y = @window.height - @weapon_gear.height*scale_weapons - weapon_offset_y
		z = 100
		@right_weapon = WeaponIndicator.new window, x,y
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
		
		
		weapon_offset_x = 90 # offset from center
		weapon_offset_y = 20 # offset from bottom of screen
		scale_weapons = 1
		
		# TODO: !!!!! Finish implementation of WeaponIndicator !!!!!
		x = @window.width/2 - weapon_offset_x - @weapon_gear.width*scale_weapons
		y = @window.height - @weapon_gear.height*scale_weapons - weapon_offset_y
		z = 100
		@left_weapon.draw x, y, scale_weapons
		
		# Right Weapon
		x = @window.width/2 + weapon_offset_x
		y = @window.height - @weapon_gear.height*scale_weapons - weapon_offset_y
		z = 100
		@right_weapon.draw x, y, scale_weapons
	end
	
	def finalize
		super
	end
end
