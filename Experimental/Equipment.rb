#!/usr/bin/ruby

class Item
	def initialize(args)
		
	end
end

class Equipment < Item
	def initialize(args)
		 
	end
	
	# Specify which points on the body the thing occupies
	attach_to	:upper_head, :middle_head, :low_head, :neck, :shoulders,
				:back, :torso, :belt, :pants, :legs, :feet,
				:right_wrist, :right_hand, :right_arm, :right_weapon, :right_ring,
				:left_wrist, :left_hand, :left_arm, :left_weapon, :left_ring
	
	#aliases for attach_to
	bind_to
	hold_in
		hold_in :left_weapon # kinda awkward
		hold_in :left_hand # assign to left-hand weapon slot
	wear_on
	put_on
end

class Weapon < Equipment
	def initialize(args)
		
	end
end

# All weapons which fire projectiles are classified under this class
# Damage depends on the properties of the weapon, and it's ammunition.
class Gun < Weapon
	def initialize(args)
		
	end
end

# Defines all non-gun weapons
# Includes melee weapons like swords and axes, as well as thrown weapons.
# Any Marital Weapon can be thrown.
# Damage depends on the 
class MartialWeapon < Weapon
	def initialize(args)
		
	end
end

class OneHandedSword < MartialWeapon
	def initialize
		
	end
end

class TwoHandedSword < MartialWeapon
	def initialize
		
	end
end


# Equipment
# 21 slots
# 2 parts per slot
# Like a 21-bit bitvector
# 2^21-1 combinations
# In general, it is
# parts**slots

# But, we have items which can occupy multiple slots
# All 5 slot


# But, they can be combined with other types

def equipment_combinations
	slots = 21
	# parts[index] == number of items with index+1 slots
	# parts.length should equal slots
	parts = [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	
	if parts.length == slots
		
	else
		return -1 # Failure state
	end
end