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

module Animation
	class Character
		attr_reader :sprites
	
		def initialize window, body, face, hair, footwear, upper, lower
			@window = window
			
			@parts = Hash.new
			set_subsprite :body, body
			set_subsprite :face, face
			set_subsprite :hair, hair
			set_subsprite :footwear, footwear
			set_subsprite :upper, upper
			set_subsprite :lower, lower
				
			generate_spritesheet
			generate_sprites
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
		
		def body= arg
			set_subsprite :body, arg
			generate_spritesheet
			generate_sprites
		end
		
		def face= arg
			set_subsprite :face, arg
			generate_spritesheet
			generate_sprites
		end
		
		def hair= arg
			set_subsprite :hair, arg
			generate_spritesheet
			generate_sprites
		end
		
		def footwear= arg
			set_subsprite :footwear, arg
			generate_spritesheet
			generate_sprites
		end
		
		def upper= arg
			set_subsprite :upper, arg
			generate_spritesheet
			generate_sprites
		end
		
		def lower= arg
			set_subsprite :lower, arg
			generate_spritesheet
			generate_sprites
		end
		
		private
		
		def generate_spritesheet
			@spritesheet = @parts[:body]
			@parts.each_pair do |key, value|
				@spritesheet.splice(value, 0,0, :alpha_blend => true) unless key == :body
			end
		end
		
		def set_subsprite type, subsprite_name
				@parts[type] = Gosu::Image.new(@window, 
								"./Sprites/People/#{type.to_s.capitalize}/#{subsprite_name}.png", 
								false)
		end
		
		def generate_sprites
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
end
