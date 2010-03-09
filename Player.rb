#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 02.04.2010

require "Title"
require "Title_Holder"
require "Character"
#Defines the player-controlled character
	#Only define attributes in this class that are PC specific
		#IE input-driven movement, mechanics of leveling up, etc
class Player < Character
	attr_accessor :titles
	Lvl_cap = 100

	def initialize(animations, pos = [0, 0, 0], dir=:down)
		super(animations, pos, dir)
		
		@titles = Title_Holder.new
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
