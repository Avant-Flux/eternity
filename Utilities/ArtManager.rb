#!/usr/bin/ruby
 
class ArtManager
	def initialize(asset_dir) #Pass the full path to the Sprites/ directory
		@dir = asset_dir
		
		#Subsprites are raw images
		#Sprites are fully composited spritesheets which have already been split
		#Animations are sprites wrapped in a interface layer for easy usage.
		#	Multiple animations can reference the same sprite
		
		@animations = {}
		@sprites = {}
		@subsprites = {:body => {}, :face => {}, :hair => {}, 	
						:upper => {}, :lower => {}, :footwear => {}}	
		@effects = {}
		@textures = {}
	end

	def new_asset(type, name, *args)
		#Load a the asset from the disk if it has not already been loaded.
		#Otherwise, simply return a reference to the asset.
		
		#To make this work, #hash for all objects used should be written
		#such that the same image will hash to the same location.
		if @assets[type][name]
			return @assets[type][name].clone
		else
			case type
				when :animation
					
				when :effect
					
				when :texture
					
			end
		end
	end
	
	def new_animation(args={})
		#Create a new animation with the subsprites specified.
		
		#~ :body, :face, :hair, :upper, :lower, :footwear
		sprite = new_sprite args
		Animation::Character.new sprite
	end
	
	def clear
		#Empty out all assets
	end
	
	private
	
	#This method may be unnecessary
	def load(type, subsprite_name)
		filepath = "#{@dir}/#{type.to_s.capitalize}/#{subsprite_name}.png"
	
		return Gosu::Image.new($window, filepath, false)
	end
	
	def new_sprite(args={})
		#Create the sprite if it does not exist in the cache.
		#Then, return a clone of the sprite in the cache.
		
		hash_code = Sprite.hash(args)
		unless @sprites[hash_code]
			#Unless there is a sprite in the cache which is the 
			#same as the sprite you are trying to generate...
			
			subsprites = Array.new
			args.each_pair do |type, name|
				subsprites << new_subsprite(type, name)
			end
			
			@sprites[hash_code] = Sprite.new 40, 80, subsprites
		end
		
		#Return a clone of the sprite so the original remains untainted.
		@sprites[hash_code].clone
	end
	
	def new_subsprite(type, name)
		#Create the subsprite if it does not exist in the cache.
		#Then, return a clone of the sprite in the cache.
		unless @subsprites[type][name]
			dir = File.join @dir, "People"
			path = File.join(dir, type.to_s.capitalize, "#{name}.png")
			
			@subsprites[type][name] = Gosu::Image.new $window, path, false
		end
		
		#Return a clone of the sprite so the original remains untainted.
		@subsprites[type][name].clone
	end
	
	def new_effect
		
	end
	
	def new_texture
		
	end
end
