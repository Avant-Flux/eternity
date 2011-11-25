#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

#~ require './Drawing/ImageCache'
#~ require './Drawing/GosuPatch'

module Image
	# Circle contains a Gosu::Image @img, instead of being a descendant of
	# Gosu::Image.  However, it should function as a Gosu::Image object.
	class Circle
		include Cacheable
		
		attr_reader :img
		
		def initialize(window, radius)
			r2 = radius * 2
			
			@img = TexPlay.create_blank_image(window, r2+2, r2+2)
			
			@img.circle(radius+1, radius+1, radius, :color => Gosu::Color::WHITE, :fill => true)
		end
		
		# TODO implement .hash and #hash
		
		def hash
			
		end
		
		def self.hash
			
		end
		
		def draw_centered(*args)
			@img.draw_centered(*args)
		end
	end
end

module Gosu
	class Image
		# Create a new image with a circle drawn on it
		def new_circle
			
		end
	end
end
