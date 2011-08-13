#!/usr/bin/ruby
 
module Creatures
	class Bat < Creature
		include Combative
		
		strength		10
		constitution	3
		dexterity		4 
		power			0
		skill			0
		flux			0
		
		def initialize(window, name)
			super(window, name, [0, 0, 0], 50, 10, lvl=1, element=:none, 0)
		end
	end
end
