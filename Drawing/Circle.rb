#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

require './Drawing/ImageCache'

module Image
	class Circle < Gosu::Image
		include Cacheable
		
		def initialize(window, radius)
			r2 = radius * 2
			
			# ===Code taken from Texplay.create_image and modified for these purposes
			super(window, TexPlay::EmptyImageStub.new(r2+2, r2+2), :caching => false)
			# ===End code taken from Texplay
			
			self.circle(radius+1, radius+1, radius, :color => Gosu::Color::WHITE, :fill => true)
		end
		
		def hash
			
		end
		
		def self.hash
			
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
