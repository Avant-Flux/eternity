#!/usr/bin/ruby
#~ Name: Jason

#~ The module Compute_Stats should be used as a mix-in with some class
#~ which contains the composite stats.
#~ Set maximum for raw stats at 300
#~ Allow user to level up to 200, with the remaining 100 being gained from titles.
#~ At this level of code, mana and flux must advance at the same rate. (ie, by the same formula)

module Compute_Stats
	MAX_HP = 10000
	MAX_MP = 10000
	MAX_ACTIVE_MP_RECOVERY_RATE = 5			#List as a multiplier on the recovery rate

	def hp
		#~ con
		#~ Max # 10,000
		a = 100/3.0
		
		(a*@con).round
	end
	
	def mp
		#~ power
		#~ Max @ 10,000 (in an attempt to make HP and MP seem similar)
		a = 100/3.0
		
		(a*@mp).round
	end
	
	def hp_recovery
		#~ con
	end
	
	def mp_recovery
		#~ flux
		#~ This stat controls only the passive recovery of mana
		#~ At max, the passive recovery should take 60 sec to fully recharge max mana
		#~ max @ 166.666667 (500/3)
	end
	
	def attack
		#~ Weapon Stats, Strength, Dexterity
		#~ Max @ 5000
		#~ 60/40 split		3000 based on stats, 2000 based on weapon
		#~ 85/15 split		2550 based on atk, 450 based on dex
		a = 8.5
		b = 1.5
		
		@weap_atk + a*@str + b*@dex
	end
	
	def defense
		#~ Armor Stats, Constitution
		#~ Max @ 5000
		#~ 60/40 split
		a = 10
		b = 20/3.0
		
		a*@armor_def + b*@con
	end
	
	def magical_attack
		#~ power
		#~ Max @ 5000
		a= 50/3.0
		
		(a*@power).ceil
	end
	
	def flux
		#~ flux and mp
		#~ Should be related to the maximum MP, so that the amount of MP and max output
		#~ 	are related, but separate.  Thus, it would be possible to have low mana and high output
		percentage = (@flux/300.0)
		percentage*MAX_MP 
	end
	
	def flux_input
		#~ Should be related to the mp recovery (proportional?)
		#~ At max, allow for 5x the recovery rate
		#~ Actually, set the recovery rate as a fraction of this
		#~ This value should be similar to the output flux
		#~ Perhaps a percentage of the output flux dictated by the power stat in proportional to
		#~ 	total power
		percentage = (@flux/300.0)
	end
	
	def flux_output
		#~ Should be related to the maximum MP, so that the amount of MP and max output
		#~ 	are related, but separate.  Thus, it would be possible to have low mana and high output
		percentage = (@flux/300.0)
		percentage*MAX_MP 
	end
	
	def flux_decompose
		#~ Flux for decomposition
	end
	
	def hit
		#~ dex
		@dex
	end
	
	def accuracy
		
	end
	
	def crit_rate
		#~ dex, luck
		#~ max @ 50%
		#~ store as a number 0-100
		#~ non-linear growth, probably logarithmic or logistic
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
