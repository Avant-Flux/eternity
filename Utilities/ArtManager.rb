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
	
	def clear
		#Empty out all assets
	end
	
	private
	
	def load(type, subsprite_name)
		filepath = "#{@dir}/#{type.to_s.capitalize}/#{subsprite_name}.png"
	
		return Gosu::Image.new($window, filepath, false)
	end
	
	def new_subsprite(name)
		
	end
	
	def new_sprite
		
	end
	
	def new_effect
		
	end
	
	def new_texture
		
	end
end
