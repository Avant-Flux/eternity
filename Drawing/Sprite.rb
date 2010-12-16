#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'

class Sprite
	def initialize(width, height, *subsprites)
		composite = nil
		
		#Splice all provided subsprites together
		subsprites.each_with_index do |image, i|
			if i == 0
				composite = sprite.clone
			else
				composite.splice(image, 0,0, :alpha_blend => true)
			end
		end
		
		@sprites = split_spritesheet composite
	end
	
	private
	
	def split_spritesheet(width, height, spritesheet)
		sprites = Hash.new
	
		sprite_array = Gosu::Image::load_tiles($window, spritesheet, width, height, false)
		
		sprite_array.each_with_index do |sprite, i|
			#Assumes that the spritesheet is broken up into rows of 8, 
			#with each column representing the frames to use in one direction
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
		
			sprites[key] << sprite
		end
		
		sprites[:down][0]
	end
end

