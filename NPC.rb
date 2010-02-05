#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 12.19.2009
 
class NPC
	attr_accessor :name
	
	def initialize(animations, name, position=[0,0,0])
		@name = name
	end
end