#!/usr/bin/ruby

module Subsprite
	def self.new(path)
		return Gosu::Image.new $window, path, false
	end
	
	def self.clone(subsprite)
		return subsprite.clone
	end
end
