#!/usr/bin/ruby
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
	
	def initialize(window, x=0,y=0,z=0)
	#~ def initialize(window, name, pos = [0, 0, 0], 
					#~ subsprites={}, mass=60, moment=20)
					
		#~ subsprites = {:body => "body", :face => "eyes", :hair => "hair", 
					#~ :upper => "shirt", :lower => "pants", :footwear => "shoes"}.merge! subsprites
		
		#~ super(window, name, pos, subsprites, mass, moment)
		super(window, x,y,z)
		
		@max_combo = 0
		@combo = 0
		@overkill_bonus = 0
		
		@equipment[:footwear] = Footgear::Shoes.new
		@equipment[:upper_body] = Upper::Shirt.new
		@equipment[:lower_body] = Lower::Pants.new
		@equipment[:outer_wear] = OuterWear::Trenchcoat.new
		
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
