#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.02.2010

#~ The module Compute_Stats should be used as a mix-in with some class
#~ which contains the composite stats.

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
		#~ Max @ 5000
		#~ 60/40 split		3000 based on stats, 2000 based on weapon
		#~ 85/15 split		2550 based on atk, 450 based on dex
		a = 0.51
		b = 0.09
		
		@weap_atk + a*@str + b*@dex
	end
	
	def defense
		#~ Armor Stats, Constitution
	end
	
	def magical_attack
		#~ power
		#~ Max @ 5000
	end
	
	def flux
		#~ flux
		@flux
	end
	
	def accuracy
		#~ dex
		@dex
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
	
	module Firearms; class << self
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
