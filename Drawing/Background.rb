#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.20.2010
require 'rubygems'
require 'gosu'

class Background
	Z_INDEX = -500

	def initialize(window, picture)
		@window = window
		@image = Gosu::Image.new(window, picture, true)
	end
	
	def update
		
	end
	
	def draw
		vert_times = (@window.height / @image.height) + 1
		horiz_times = (@window.width / @image.width) + 1
		
		#~ puts "#{@window.height}  #{@image.height}" 
		
		vert_times.times do |y|
			horiz_times.times do |x|
				@image.draw(@image.width * x, @image.height * y, Z_INDEX)
			end
		end
	end
end
