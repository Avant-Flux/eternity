#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.18.2010
require 'set'
 
class Camera
	def initialize(width, depth, entity)
		@queue = Set.new
	end
end
