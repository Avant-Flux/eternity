#!/usr/bin/ruby

#This class exists to store and manage art assets for the game.
#There should be some measure so that when the assets are no
#longer needed, the memory can be freed.
class ArtManager
	def initialize(asset_dir) #Pass the full path to the Sprites/ directory
		@dir = asset_dir
		
		#Subsprites are raw images
		#Sprites are fully composited spritesheets which have already been split
		#Animations are sprites wrapped in a interface layer for easy usage.
		#	Multiple animations can reference the same sprite
		
		@circles = {}	#These can be used for the tracking blips, shadows, etc
		
		#~ @animations = {}
		@sprites = {}
		@subsprites = {:body => {}, :face => {}, :hair => {}, 
						:upper => {}, :lower => {}, :footwear => {}}
		@effects = {}
		@textures = {}
	end
	
	#Create a new animation with the subsprites specified in the hash argument.
	def new_animation(args={})
		#~ :body, :face, :hair, :upper, :lower, :footwear
		sprite = new_sprite args
		Animation::Character.new sprite
	end
	
	def new_effect
		
	end
	
	def new_texture
		
	end
	
	def new_shadow(entity)
		Shadow.new entity, new_circle(entity.width/2)
	end
	
	def new_blip(player, entity, ellipse)
		circle = new_circle UI::Overlay::Blip::MAX_RADIUS
		UI::Overlay::Blip.new player, entity, circle, ellipse
	end
	
	#Empty out all assets
	def clear
		clear_all_subsprites
		clear_all_sprites
		clear_all_effects
		clear_all_textures
	end
	
	def clear_subsprite(type, name)
		@subsprites[type].delete name
	end
	
	def clear_sprite(args={})
		hash_code = Sprite.code args
		@sprite.delete hash_code
	end
	
	def clear_effect
		
	end
	
	def clear_texture
		
	end
	
	def clear_circle(radius)
		@circles.delete radius
	end
	
	def clear_all_subsprites
		@subsprites.each_key do |key|
			@subsprites[key] = Hash.new
		end
	end
	
	def clear_all_sprites
		@sprites.clear
	end
	
	def clear_all_effects
		@effects.clear
	end
	
	def clear_all_textures
		@textures.clear
	end
	
	def clear_all_circles
		@circles.clear
	end
	
	private
	
	#This method may be unnecessary
	def load(type, subsprite_name)
		filepath = "#{@dir}/#{type.to_s.capitalize}/#{subsprite_name}.png"
	
		return Gosu::Image.new($window, filepath, false)
	end
	
	#Create the sprite if it does not exist in the cache.
	#Then, return a reference to the sprite in the cache.
	def new_sprite(args={})
		hash_code = Sprite.code(args)
		unless @sprites[hash_code]
			#Unless there is a sprite in the cache which is the 
			#same as the sprite you are trying to generate...
			
			subsprites = Array.new
			args.each_pair do |type, name|
				subsprites << new_subsprite(type, name)
			end
			
			@sprites[hash_code] = Sprite.new 40, 80, subsprites
		end
		
		#Return a reference the cached sprite.
		#No cloning is needed as this sprite will never be edited.
		@sprites[hash_code]
	end
	
	#Create the subsprite if it does not exist in the cache.
	#Then, return a reference to the sprite in the cache.
	def new_subsprite(type, name)
		unless @subsprites[type][name]
			path = File.join(@dir, "People", type.to_s.capitalize, "#{name}.png")
			
			@subsprites[type][name] = Gosu::Image.new $window, path, false
		end
		
		#Return a clone of the sprite so the original remains untainted.
		@subsprites[type][name]
	end
	
	#Creates a new circle.  All circles will be white,
	#so that they can be colored dynamically in opengl.
	#Only one circle will be stored per radius.
	def new_circle(radius)
		unless @circles[radius]
			r2 = radius * 2
			@circles[radius] = TexPlay.create_blank_image($window, r2+2, r2+2)
			@circles[radius].circle(radius+1, radius+1, radius, 
									:color => Gosu::Color::WHITE, :fill => true)
		end
		
		@circles[radius]
	end
end
