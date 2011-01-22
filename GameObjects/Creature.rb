#!/usr/bin/ruby
 
require "./GameObjects/Entity"
class Creature < Entity
	def initialize(animations, name, pos=[0, 0, 0], mass=50, moment=10, dir=:down,
					lvl=1, element=:none, 
					stats={:str => 1, :con => 1, :dex => 1, :agi => 1, :luk => 1,
							:pwr => 1, :ctl => 1, :per => 1}, 
					faction = 0)
		super(space, animations, name, pos, mass, moment, lvl, element, stats, faction)
	end
end
