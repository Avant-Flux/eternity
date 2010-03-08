#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 12.19.2009
 
require "Entity"
class Creature < Entity
	def initialize(animations, pos=[0, 0, 0], dir=:down
					lvl=1, hp=5, mp=0, element=:none, 
					stats=[1,1,1,1,1,1,1,1], 
					faction = 0)
		super(animations, pos, dir, lvl, hp, mp, element, stats, faction)
	end
end
