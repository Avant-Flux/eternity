#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.22.2010
 
require "Entity"
class Creature < Entity
	def initialize(window, space, name, pos=[0, 0, 0], mass=50, moment=10, dir=:down,
					lvl=1, element=:none, 
					stats={:str => 1, :con => 1, :dex => 1, :agi => 1, :luk => 1,
							:pwr => 1, :ctl => 1, :per => 1}, 
					faction = 0)
		super(window, space, name, pos, dir, lvl, mass, moment, element, stats, faction)
	end
end
