#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

#~ require './Drawing/ImageCache'

# Animations need only be generated at 12fps.  There is not too much difference
# in appearance between 12fps and 24fps

module Animation
	class Entity
		include Cacheable
		
		def initialize(window, subsprites)
			# Get the sprite data for the given subsprites
			@sprites = Sprite.new window, subsprites
			
			# Set default values for the animation
			@moving = false
			@current_frame = @sprites[:down][0]
		end
		
		def update(moving, direction)
			if moving
				#Advance the animation to the next appropriate frame
				#Do not include the logic of WHEN to advance (or maybe...?)
				@current_frame = @sprites[direction][0]#[Gosu::milliseconds/100%@sprites[direction].size]
			else
				@current_frame = @sprites[direction][0]
			end
		end
		
		def draw(x,y,z, zoom)
			@current_frame.draw(x,y - z,z, zoom, :offset_x => :centered, :offset_y => :height)
		end
		
		def self.load path
			
		end
		
		def save
			
		end
		
		def clone
			output = Animations::Entity.new(@sprite)
		end
		
		def ==(arg)
			if arg.is_a? Animation::Entity
				arg.sprites == @sprites
			else
				super.== arg
			end
		end
		
		# TODO implement .hash and #hash
		
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
		
		class << self
			# Advance animations system by one step
			def step
				
			end
			
			# Manage the update rate for the whole animations system.
			# Should be the same as the hz rate of the physics system
			# ie, if the game runs at 60fps, this value should be 60
			attr_accessor :update_rate
		end
	end

	class Character < Animation::Entity
		def initialize sprite
			super(sprite)
			#should be 40 wide and 80 tall
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
