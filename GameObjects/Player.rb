#!/usr/bin/ruby
require 'rubygems'
require 'require_all'


require "./GameObjects/Character"

require "./Titles/Title"
require "./Titles/Title_Holder"
require_all "./UI"
#Defines the player-controlled character
	#Only define attributes in this class that are PC specific
		#IE input-driven movement, mechanics of leveling up, etc
class Player < Character
	attr_accessor :titles, :max_combo, :combo, :overkill_bonus
	Lvl_cap = 100
	
	strength		12
	constitution	9
	dexterity		6 
	power			6
	control			3
	flux			9

	def initialize(window, name, pos = [0, 0, 0], 
					subsprites={}, mass=60, moment=20)
					
		subsprites = {:body => 1, :face => 1, :hair => 1, 
					:upper => "shirt1", :lower => "pants1", :footwear => "shoes1"}.merge! subsprites
		
		super(window, name, pos, subsprites, mass, moment)
		
		@max_combo = 0
		@combo = 0
		@overkill_bonus = 0
		
		#~ @tracker = UI::Overlay::Tracking.new(self)
	end
	
	def update
		super
		#~ @tracker.update
	end
	
	#~ def draw
		#~ super
		#~ @tracker.draw
	#~ end
	
	def create
		
	end
	
	def load
		
	end
	
	def save
		
	end
	
	def track(entity)
		#~ @tracker.track(entity)
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
