#!/usr/bin/ruby
 
class Creature < Entity
	def initialize(window, name, pos=[0, 0, 0], mass=50, moment=10, lvl=1, element=:none, 
					faction = 0)
					
		animations = Struct.new(:width).new(2)
		
		super(window, animations, name, pos, mass, moment, lvl, element, faction)
	end
end
