#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.20.2010
require 'rubygems'
require 'gosu'
require 'texplay'

class Animations
	FILEPATH = "Sprites/People/Body/1.png"

	def Animations.player(window)
		@sprites = Gosu::Image::load_tiles(window, FILEPATH, 40, 80, false)
		
		#Map each hash key in animations to an empty array
		@animations = {:up => [], :down => [], :left => [], :right => [], 
					:up_right => [], :up_left => [], :down_right => [], :down_left => []}
		
		create_base
		splice_hair
		splice_face
		splice_upper_body
		splice_lower_body
		splice_footwear
	end
	
	def splice arg
		@animations.each_pair do |key, value|
			arg.animations[key].each_with_index do |other_sprite, index|
				@animations[key][index].splice(other_sprite, 0, 0)
			end
		end
	end
	
	private
	
	def create_base
		@sprites.each_with_index do |sprite, i|
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
		
			@animations[key] << sprite
		end
	end
	
	def splice_hair
		
	end
	
	def splice_face
		
	end
	
	def splice_upper_body
		
	end
	
	def splice_lower_body
		
	end
	
	def splice_footwear
		
	end
end
