#!/usr/bin/ruby
 
require "./GameObjects/Entity"
class Creature < Entity
	def initialize(window, name, pos=[0, 0, 0], mass=50, moment=10, lvl=1, element=:none, 
					stats={}, faction = 0)
					
		stats = {:strength => 10, :constitution => 10, :dexterity => 10, 
				:power => 10, :skill => 10, :flux => 10}.merge! stats
		
		animations = Struct.new(:width).new(2)
		
		super(window, animations, name, pos, mass, moment, lvl, element, stats, faction)
	end
end
