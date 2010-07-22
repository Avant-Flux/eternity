#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.03.2010
require 'rubygems'
require 'gosu'
require 'texplay'

#Texplay modification to allow for chopping texplay images into tiles
#~ class Gosu::Image
   #~ alias_method :rows, :height
   #~ alias_method :columns, :width
#~ end

module Animations
	class Entity			#Only inherit from this class, never create objects of it
		attr_reader :sprites
		attr_accessor :direction, :moving
		
		def initialize(window)
			@window = window
			@sprites = {:up => [], :down => [], :left => [], :right => [], 
						:up_right => [], :up_left => [], :down_right => [], :down_left => []}
			@moving = false
		end
		
		class << self
			def load path
				
			end
		end
		
		def save
				
		end
		
		def [](key)
			@sprites[key]
		end
		
		def []=(key, arg)
			@sprites[key] = arg
		end
		
		def width
			@current_frame.width
		end
		
		def height
			@current_frame.height
		end
		
		def update
			if @moving
				#Advance the animation to the next appropriate frame
				#Do not include the logic of WHEN to advance (or maybe...?)
				@current_frame = @sprites[@direction][Gosu::milliseconds/100%@sprites[@direction].size]
			else
				@current_frame = @sprites[@direction][0]
			end
		end
		
		def draw(x,y,z)
			@current_frame.draw(x-@current_frame.width/2, 
								(y - z)-@current_frame.height, 
								z + y)
		end
		
		private
		
		def make_sprites
			sprite_array = Gosu::Image::load_tiles(@window, @spritesheet, 40, 80, false)
			
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
			
			@direction = :down
			@current_frame = @sprites[@direction][0]
		end
		
		def subsprites basepath, type, subsprite_name
			return Gosu::Image.new(@window, 
						"#{basepath}/#{type.to_s.capitalize}/#{subsprite_name}.png", false)
		end
	end

	class Character < Entity
		attr_accessor :body, :face, :hair, :upper, :lower, :footwear
	
		def initialize window, body, face, hair, upper, lower, footwear
			super(window)		
			@body = body
			@face = face
			@hair = hair
			@upper = upper
			@lower = lower
			@footwear = footwear
			
			make_spritesheet
			make_sprites
		end
		
		private
		
		def make_spritesheet
			@spritesheet = subsprites :body, @body
			@spritesheet.splice(subsprites(:face, @face), 0,0, :alpha_blend => true)
			@spritesheet.splice(subsprites(:hair, @hair), 0,0, :alpha_blend => true)
			@spritesheet.splice(subsprites(:upper, @upper), 0,0, :alpha_blend => true)
			@spritesheet.splice(subsprites(:lower, @lower), 0,0, :alpha_blend => true)
			@spritesheet.splice(subsprites(:footwear, @footwear), 0,0, :alpha_blend => true)
		end
		
		def subsprites type, subsprite_name
			super "./Sprites/People", type, subsprite_name
		end
	end
	
	class Effect
		attr_reader :name, :current_frame
	
		def initialize(window, name_of_effect)
			@window = window
			@name = name_of_effect
			@sprites = Gosu::Image::load_tiles(@window, "./Sprites/Effects/#{@name}.png", 
												192, 192, false)
			update
		end
		
		def update
			@current_frame = @sprites[Gosu::milliseconds / 100 % @sprites.size]
		end
		
		def draw(x,y,z)
			@current_frame.draw(x,y,z)
		end
	end
end
