#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.20.2010
 
require "Entity"
class Creature < Entity
	def initialize(space, name, pos=[0, 0, 0], dir=:down,
					lvl=1, hp=5, mp=0, element=:none, 
					stats=[1,1,1,1,1,1,1,1], 
					faction = 0)
		super(space, name, animations, pos, dir, lvl, hp, mp, element, stats, faction)
	end
end
