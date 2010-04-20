#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 04.20.2010

require "Title"
require "Title_Holder"
require "Character"
#Defines the player-controlled character
	#Only define attributes in this class that are PC specific
		#IE input-driven movement, mechanics of leveling up, etc
class Player < Character
	attr_accessor :titles, :max_combo, :combo, :overkill_bonus
	Lvl_cap = 100

	def initialize(name, animations, pos = [0, 0, 0], dir=:down)
		super(name, animations, pos, dir)
		
		@max_combo = 0
		@combo = 0
		@overkill_bonus = 0
	end
	
	def create
		
	end
	
	def load
		
	end
	
	def save
		
	end
	
	def lvl_up
		self.lvl = @lvl + 1 unless @lvl == Lvl_cap
	end
	
	def equip e
		e.apply_effect self
	end
	
	def unequip e
		e.remove_effect self
	end
end
