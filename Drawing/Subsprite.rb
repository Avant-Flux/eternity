#!/usr/bin/ruby
require 'rubygems'
require 'gosu'

class Subsprite < Gosu::Image
	attr_reader :type, :id

	def initialize(path)
		super $window, path, false
	end
	
	#~ def clone()
		#~ super()
	#~ end
end
