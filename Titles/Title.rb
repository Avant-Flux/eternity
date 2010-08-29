#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 12.22.2009
 
class Title
	attr_reader :name, :description, :effect, :points

	def initialize(name, description, effect, points=100)
		@name = name
		@description = description
		@effect = effect
		@points = points
	end
	
	def <=>(arg)
		if arg.class == Title
			if @name > arg.name
				1
			elsif @name < arg.name
				-1
			else #@name == arg.name
				0
			end
		end
	end
end