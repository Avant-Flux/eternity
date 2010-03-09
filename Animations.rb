#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 03.08.2010
require 'rubygems'
require 'gosu' 

module Animations
	def player
		sprites = Gosu::Image::load_tiles(self, "Sprites/Sprites.png", 40, 80, false)
		#Map each hash key in animations to an empty array
		animations = {:up => [], :down => [], :left => [], :right => [], 
					:up_right => [], :up_left => [], :down_right => [], :down_left => []}
		
		sprites.each_with_index do |sprite, i|
			#Assumes that the spritesheet is broken up into rows of 8, with each column representing
			#the frames to use in one direction
			key = case i % 8
				when 0
					:up
				when 1
					:down
				when 2
					:left
				when 3
					:right
				when 4
					:up_right
				when 5
					:up_left
				when 6
					:down_right
				when 7
					:down_left
			end
		
			animations[key] << sprite
		end
		
		animations
	end
end
