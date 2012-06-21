#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
#~ require 'texplay'

require './Drawing/ImageCache'

class Sprite
	include Cacheable
	
	WIDTH = 295
	HEIGHT = 640
	
	def initialize(window, subsprites)
		#~ # Get all subsprites
		#~ layers = []
		#~ # List the different types in order from lowest z index to highest
		#~ types = [:body, :face, :hair, :upper, :lower, :shoes]
		
		#~ types.each do |type|
			#~ if subsprites[type]
				#~ layers << Subsprite.new(window, type, subsprites[type])#subsprites[type]
			#~ end
		#~ end
		#~ 
		#~ composite = nil
		
		#~ #Splice all provided subsprites together
		#~ layers.each_with_index do |image, i|
			#~ if i == 0
				#~ composite = image.clone
			#~ else
				#~ composite.splice(image, 0,0, :alpha_blend => true)
			#~ end
		#~ end
		
		spritesheet = File.join(Cacheable.sprite_directory, "People", "NewSprites.png")
		sprites = Gosu::Image::load_tiles(window, spritesheet, WIDTH, HEIGHT, false)
		#~ sprites = Gosu::Image::load_tiles(window, composite, WIDTH, HEIGHT, false)
		
		@sprites = {:up => [], :down => [], :left => [], :right => []}
		@sprites[:up] << sprites[0]
		@sprites[:down] << sprites[1]
		@sprites[:left] << sprites[2]
		@sprites[:right] << sprites[3]
	end
	
	#~ def method_missing(symbol, *args)
		#~ @sprites.send(symbol, *args)
	#~ end
	
	def [](arg)
		@sprites[arg]
	end
	
	#~ def []=(key, arg)
		#~ @sprites[key] = arg
	#~ end
	
	def self.code(args)
		#Compute the hash code of a Sprite with the given subsprites
		args.hash
	end
	
	def hash
		#Compute the hash code for this Sprite
		1
	end
	
	private
	
	def split_spritesheet(window, width, height, spritesheet)
		sprites = {:up => [], :down => [], :left => [], :right => [],
					:up_left => [], :up_right => [], :down_left => [], :down_right => []}
	
		sprite_array = Gosu::Image::load_tiles(window, spritesheet, width, height, false)
		
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
		
		sprites
	end
end

