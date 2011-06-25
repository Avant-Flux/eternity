#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

require './Drawing/ImageCache'

class Subsprite < Gosu::Image
	include Cacheable
	
	def initialize(window, type, name)
		# Type specifies the type of asset, while name specifies the specific asset to load
		path = File.join(Cacheable.sprite_directory, "People", type.to_s.capitalize, "#{name}.png")
		
		super(window, path, false)
	end
	
	# TODO implement .hash and #hash
end
