#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.14.2010

require "GameObjects/Character"

require "Titles/Title"
require "Titles/Title_Holder"
require "UI/UserInterface"
#Defines the player-controlled character
	#Only define attributes in this class that are PC specific
		#IE input-driven movement, mechanics of leveling up, etc
class Player < Character
	attr_accessor :titles, :max_combo, :combo, :overkill_bonus
	Lvl_cap = 100

	def initialize(window, space, name, pos = [0, 0, 0], 
					subsprites={:body => 1, :face => 1, :hair => 1, 
								:upper => "shirt1", :lower => "pants1", :footwear => "shoes1"}, 
					mass=120, moment=20)
		super(window, space, name, pos, subsprites, mass, moment)
		
		@max_combo = 0
		@combo = 0
		@overkill_bonus = 0
		
		@tracker = UI::Overlay::Tracking.new(window, self)
		@UI = UI::Overlay::Status.new(window, self)
	end
	
	def update
		super
		@tracker.update
		@UI.update
	end
	
	def draw
		super
		@tracker.draw
		@UI.draw
	end
	
	def create
		
	end
	
	def load
		
	end
	
	def save
		
	end
	
	def track(entity)
		@tracker.track(entity)
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