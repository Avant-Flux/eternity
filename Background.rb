#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.20.2010
require 'rubygems'
require 'gosu'

class Background
	def initialize(window, picture)
		@window = window
		@image = Gosu::Image.new(window, picture, true)
	end
	
	def update
		
	end
	
	def draw
		(0..(@window.height)).step(@image.height) do |h|
			(0..(@window.width)).step(@image.width) do |w|
				@image.draw(h,w, -500)
			end
		end
	end
end
