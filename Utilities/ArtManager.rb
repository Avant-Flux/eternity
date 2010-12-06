#!/usr/bin/ruby
 
class ArtManager
	def initialize(asset_dir) #Pass the full path to the Sprites/ directory
		@dir = asset_dir
		
		#The structure of the @assets hash should mirror the file structure
		#Could alternatively use a tree
		@assets = {:effects => [], :people => [], :textures => []}
	end
	
	def new_asset(type, name)
		#Load a the asset from the disk if it has not already been loaded.
		#Otherwise, simply return a reference to the asset.
		
		#To make this work, #hash for all objects used should be written
		#such that the same image will hash to the same location.
	end
	
	def clear
		#Empty out all assets
	end
end
