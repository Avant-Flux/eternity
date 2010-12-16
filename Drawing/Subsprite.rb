#!/usr/bin/ruby

class Subsprite
	attr_accessor :img

	def initialize
		
	end
	
	def load(path)
		@img = Gosu::Image.new $window, path, false
	end
	
	def clone
		subsprite = Subsprite.new
		subsprite.img = @img
		return subsprite
	end
end
