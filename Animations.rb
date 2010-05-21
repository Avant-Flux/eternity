#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.21.2010
require 'rubygems'
require 'gosu'
require 'texplay'

module Gosu
class Image
	
end
end

class Animations
	FILEPATH = "Sprites/People/Body/1.png"
	
	attr_reader :animations

	def initialize(window, type=:people, sector=:body, number=1)
		filepath = "Sprites/#{type.to_s.capitalize}/#{sector.to_s.capitalize}/#{number}.png"
		@animations = generate_sprites window, filepath
		
		
		#~ base = generate_sprites window, "Sprites/People/Body/1.png"
		#~ hair = generate_sprites window, "Sprites/People/Hair/1.png"
		#~ base.each_pair do |key, value|
			#~ value[0].splice hair[key][0],0,0, :alpha_blend => true
		#~ end
		
		#~ @animations = base
	end
	
	def [](key)
		@animations[key]
	end
	
	def splice arg
		#~ @animations[:up][0].splice arg.animations[:up][0], 0, 0
		#~ @animations[:down][0].splice arg.animations[:down][0], 0, 0
		#~ @animations[:left][0].splice arg.animations[:left][0], 0, 0
		#~ @animations[:right][0].splice arg.animations[:right][0], 0, 0
	#~ 
		@animations.each_pair do |key, value|
			arg.animations[key].each_with_index do |other_sprite, index|
				#~ puts "#{other_sprite} => #{index}"
				@animations[key][index].splice(other_sprite, 0, 0, :alpha_blend => true)
			end
		end
	end
	
	private
	
	def generate_sprites window, path
		sprites = Gosu::Image::load_tiles(window, path, 40, 80, false)
		animations = {:up => [], :down => [], :left => [], :right => [], 
					:up_right => [], :up_left => [], :down_right => [], :down_left => []}
		
		sprites.each_with_index do |sprite, i|
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
		
			animations[key] << sprite
		end
		
		return animations
	end
end
