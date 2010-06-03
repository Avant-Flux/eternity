#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.03.2010

require "Character"

require "Title"
require "Title_Holder"
require "UserInterface"
#Defines the player-controlled character
	#Only define attributes in this class that are PC specific
		#IE input-driven movement, mechanics of leveling up, etc
class Player < Character
	attr_accessor :titles, :max_combo, :combo, :overkill_bonus
	Lvl_cap = 100

	def initialize(window, space, name, pos = [0, 0, 0])
		super(window, space, name, pos)
		
		@max_combo = 0
		@combo = 0
		@overkill_bonus = 0
		
		@tracker = Tracking_Overlay.new(window, self)
	end
	
	def update
		super
	end
	
	def draw
		super
		@tracker.draw
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
