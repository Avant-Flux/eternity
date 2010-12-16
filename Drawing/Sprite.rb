#!/usr/bin/ruby

class Sprite
	def initialize
		
	end
	
	def make_sprites
			sprite_array = Gosu::Image::load_tiles($window, @spritesheet, 40, 80, false)
			
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
			
			@current_frame = @sprites[:down][0]
		end
	
	def make_spritesheet body, face, hair, upper, lower, footwear
		@spritesheet = TexPlay.create_blank_image $window, body.width, body.height
		
		@spritesheet.splice(body, 0,0, :alpha_blend => true)
		@spritesheet.splice(face, 0,0, :alpha_blend => true)
		@spritesheet.splice(hair, 0,0, :alpha_blend => true)
		@spritesheet.splice(upper, 0,0, :alpha_blend => true)
		@spritesheet.splice(lower, 0,0, :alpha_blend => true)
		@spritesheet.splice(footwear, 0,0, :alpha_blend => true)
	end
end

