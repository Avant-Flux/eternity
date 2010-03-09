#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 03.08.2010
require 'rubygems'
require 'gosu' 

module Animations
	def Animations.player(window)
		sprites = Gosu::Image::load_tiles(window, "Sprites/Sprites.png", 40, 80, false)
		#Map each hash key in animations to an empty array
		animations = {:up => [], :down => [], :left => [], :right => [], 
					:up_right => [], :up_left => [], :down_right => [], :down_left => []}
		
		sprites.each_with_index do |sprite, i|
			#Assumes that the spritesheet is broken up into rows of 8, with each column representing
			#the frames to use in one direction
			key = case i % 8
				when 0
					:up_left
				when 1
					:left
				when 2
					:down_left
				when 3
					:down
				when 4
					:down_right
				when 5
					:right
				when 6
					:up_right
				when 7
					:up
			end
		
			animations[key] << sprite
		end
		
		animations
	end
end
