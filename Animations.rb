#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.27.2010
require 'rubygems'
require 'gosu'
require 'texplay'

#Texplay modification to allow for chopping texplay images into tiles
class Gosu::Image
   alias_method :rows, :height
   alias_method :columns, :width
end

module Animations
	class Entity
		def make_sprites
			sprite_array = Gosu::Image::load_tiles(@window, @spritesheet, 40, 80, false)
			@sprites = {:up => [], :down => [], :left => [], :right => [], 
						:up_right => [], :up_left => [], :down_right => [], :down_left => []}
			
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
			
				@sprites[key] << sprite
			end
		end
	end

	class Character < Entity
		attr_reader :sprites
		attr_accessor :body, :face, :hair, :upper, :lower, :footwear
	
		def initialize window, body, face, hair, upper, lower, footwear
			@window = window
			@body = body
			@face = face
			@hair = hair
			@upper = upper
			@lower = lower
			@footwear = footwear
			
			make_spritesheet
			make_sprites
		end
		
		class << self
			def load path
				
			end
		end
		
		def [](key)
			@sprites[key]
		end
		
		def []=(key, arg)
			@sprites[key] = arg
		end
		
		private
		
		def subsprites type, subsprite_name
			return Gosu::Image.new(@window, 
						"./Sprites/People/#{type.to_s.capitalize}/#{subsprite_name}.png", false)
		end
		
		def make_spritesheet
			@spritesheet = subsprites :body, @body
			@spritesheet.splice(subsprites(:face, @face) ,0,0, :alpha_blend => true)
			@spritesheet.splice(subsprites(:hair, @hair) ,0,0, :alpha_blend => true)
			@spritesheet.splice(subsprites(:upper, @upper) ,0,0, :alpha_blend => true)
			@spritesheet.splice(subsprites(:lower, @lower) ,0,0, :alpha_blend => true)
			@spritesheet.splice(subsprites(:footwear, @footwear) ,0,0, :alpha_blend => true)
		end
	end
end
