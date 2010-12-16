#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

module Animations
	class Entity			#Only inherit from this class, never create objects of it
		attr_reader :sprites
		attr_accessor :direction, :moving
		
		def initialize
			@sprites = {:up => [], :down => [], :left => [], :right => [], 
						:up_right => [], :up_left => [], :down_right => [], :down_left => []}
			@moving = false
		end
		
		def update(moving, direction)
			if moving
				#Advance the animation to the next appropriate frame
				#Do not include the logic of WHEN to advance (or maybe...?)
				@current_frame = @sprites[direction][Gosu::milliseconds/100%@sprites[direction].size]
			else
				@current_frame = @sprites[direction][0]
			end
		end
		
		def draw(x,y,z)
			@current_frame.draw(x,y,z, {:offset_x => :centered, :offset_y => :height})
		end
		
		def self.load path
			
		end
		
		def save
				
		end
		
		def clone
			
		end
		
		def hash
			#Create an identifier such that all animations which use 
			#the same subsprites will have the same identifier
			
			#Create a hex number where each two hex-digits corresponds
			#to one subsprite.
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
		
		
		private
		
		def subsprites basepath, type, subsprite_name
			return Gosu::Image.new($window, 
						"#{basepath}/#{type.to_s.capitalize}/#{subsprite_name}.png", false)
		end
	end

	class Character < Animations::Entity
		def initialize body, face, hair, upper, lower, footwear
			super()

			make_spritesheet subsprites
			make_sprites #should be 40 wide and 80 tall
		end
		
		private
		
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
