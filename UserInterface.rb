#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.06.2010

require 'rubygems'
require 'gosu'
require 'chingu'

require 'chipmunk'
require 'ChipmunkInterfaceMod'

require 'RMagick'

require 'Entity'
require "Creature"
require 'Character'
require 'Player'

class Hud
	def initialize
		
	end
	
	def update
		
	end
	
	def draw
		
	end
end

#This class renders the overlay which shows the position of tracked entities
#	In order to render this effect is psudo-perspective without a global perspective warp,
#	render the tracking blips along an ellipse which simulates a circle in perspective.
#
#	Calculate an ellipse and project the rendering of the blip onto it.
#	Calculate the position of the blip by getting the angle between the player and the entity
#	to be tracked.
class Tracking_Overlay
	STROKE_WIDTH = 3
	PADDING = STROKE_WIDTH/2+10

	RX = 120
	RY = 80
	
	IMAGE_WIDTH = RX*2+PADDING*2
	IMAGE_HEIGHT = RY*2+PADDING*2
	
	def initialize(window, player)
		@window = window
		@player = player
		@tracked = Array.new
		
		canvas = Magick::Image.new(IMAGE_WIDTH, IMAGE_HEIGHT) do
			self.background_color = "transparent"
		end
		gc = Magick::Draw.new
		
		gc.stroke('red')
		gc.stroke_width(STROKE_WIDTH)
		gc.fill_opacity(0)
		gc.ellipse(IMAGE_WIDTH/2,IMAGE_HEIGHT/2, RX,RY, 0,360)
		
		gc.draw(canvas)
		@ellipse = Gosu::Image.new(@window, canvas, false)
	end
	
	def track(entity)
		@tracked  << Blip.new(@window, @player, entity)
	end
	
	def untrack(entity)
		#Remove from @tracked
		@tracked.delete_if {|x| x.entity == entity}
	end
	
	def update
		@tracked.each_pair do |entity, blip|
			
		end
	end
	
	def draw
		x = @player.body.x-IMAGE_WIDTH/2
		y = @player.body.y-IMAGE_HEIGHT/2-@player.body.z-@player.animations.height/6
		z = @player.body.z+10+@player.body.y
		
		@ellipse.draw x, y, z
		
		@tracked.each_value do |blip|
			blip.draw z
		end
	end
	
	private
	
	def angle_to(entity)	#This method needs a better name which make sense when it's called
		x = entity.body.x - @player.body.x
		y = entity.body.y - @player.body.y
		
		#Produce an angle in degrees in the Gosu reference frame
		CP::Vec2.new(x,y).to_angle*(180/Math::PI)-90
	end
	
	class Blip
		MAX_RADIUS = 20
		CENTER = MAX_RADIUS/2
		
		attr_accessor :entity
		
		def initialize(window, player, entity)
			@x = x
			@y = y
			@distance = distance
			@radius = calculate_radius
			
			@image = TexPlay.create_blank_image(window, MAX_RADIUS*2, MAX_RADIUS*2)
		end
		
		def update
			
		end
		
		def render
			@image.paint do
				circle CENTER, CENTER, @radius
			end
		end
		
		def draw(z_index=1)
			@image.draw @x-CENTER, @y-z_index-CENTER, z_index + @y
		end
		
		private
		
		def elliptical_projection(entity)
			#Calculate the corresponding position of a tracking blip for a given entity
			#The trig functions in ruby take the angle in radians
			x = @player.body.x + RX*Math.cos()
		end
		
		def clear_image
			@image = TexPlay.create_blank_image(window, MAX_RADIUS*2, MAX_RADIUS*2)
		end
		
		def calculate_radius
			constant = 25
			(constant/@distance)*Math.sqrt(2/Math::PI)
		end
	end
end
