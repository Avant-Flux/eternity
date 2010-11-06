#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require './Drawing/GosuPatch'

module Shadow
	class ShadowObject
		@@images = Hash.new
		
		def initialize(type, entity)
			@entity = entity
		
			unless @@images[type]
				radius = @entity.width/2
				r2 = radius * 2
				
				@@images[type] = TexPlay.create_blank_image($window, r2+2, r2+2)
				@@images[type].circle(radius+1, radius+1, radius, 
										:color => Gosu::Color::WHITE, :fill => true)
			end
		end
		
		def update
			@color = color
			@scale = scale
		end
		
		def draw(type)
			@@images[type].draw_centered(@entity.x.to_px, @entity.y.to_px - @entity.elevation.to_px, 
									@entity.z.to_px, @scale, @scale, @color)
		end
		
		private
		
		def color
			#~ Calculate the color of the shadow to be rendered, and mix in
			#~ The correct opacity
			color = 0x0000FF
			color += opacity * 0x1000000
		end
		
		def opacity
			percent = 0.2
			0xFF * percent
		end
		
		def scale
			#~ Calculate the amount by which to scale the shadow
			1
			#~ (@entity.elevation + 1)
		end
	end
	
	class Human < ShadowObject
		def initialize(entity)
			super :human, entity
		end
		
		def update
			super
		end
		
		def draw
			super :human
		end
	end
end
