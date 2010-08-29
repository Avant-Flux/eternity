#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 08.28.2010
 
module Compute_Stats
	def hp
		#~ con
	end
	
	def mp
		#~ power
	end
	
	def hp_recovery
		#~ con
	end
	
	def mp_recovery
		#~ flux
	end
	
	def attack
		#~ Weapon Stats, Strength, Dexterity
	end
	
	def defense
		#~ Armor Stats, Constitution
	end
	
	def magical_attack
		#~ power
	end
	
	def flux
		#~ flux
	end
	
	def accuracy
		#~ dex
	end
	
	def crit_rate
		#~ dex, luck
	end
	
	def dodge_rate
		#~ Agility, weight, weapon size, Luck
	end
	
	def weapon_range
		#~ Weapon type, Weapon size
	end
	
	def magic_range
		#~ power
	end

	def weapon_speed
		#~ Weapon type, weapon size(non-firearms), Dexterity, Agility
	end
	
	def magic_speed
		#~ flux
	end
	
	def weight_limit
		#~ str
	end
	
	def current_weight
		#~ Constitution, Armor Weight, Weapon Weight
	end
	
	def movement_speed
		#~ Weight Agility, Strength
	end
	
	def jump_height
		#~ Strength, Agility
	end
		
	def effect_area
		#~ power
	end
	
	def effect_density
		#~ Control, Perception, Luck
	end
	
	def mana_sense
		#~ perception
	end
	
	module Firearms; class << self;
		def recoil
			#~ weapon type, weapon power, weight, Strength
		end
		
		def reload_time
			#~ weapon type, Flux, Power
		end
		
		def attack_speed
			#~ weapon type, weapon modifiers, Dexterity
		end 
	end; end
end
