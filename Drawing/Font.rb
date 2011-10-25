#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

class Font < Gosu::Font
	# Implement caching functionality

	def initialize(*args)
		super(*args)
	end
end
