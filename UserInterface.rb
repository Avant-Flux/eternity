#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.03.2010

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
		@tracked = Hash.new
		
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
		@tracked[entity] = Blip.new(@window, 1,1, 10)
	end
	
	def untrack(entity)
		#Remove from @tracked
		@tracked.delete_if do |key, val|
			key == entity
		end
	end
	
	def update
		@tracked.each_pair do |key, val|
			
		end
	end
	
	def draw
		Blip.all.each {|b| b.draw}
		@ellipse.draw @player.body.x-IMAGE_WIDTH/2, @player.body.y-IMAGE_HEIGHT/2, @player.body.z+10
	end
	
	private
	
	def calculate_position
		
	end
	
	class Blip
		MAX_RADIUS = 20
		CENTER = MAX_RADIUS/2
		Z_INDEX = 1
		
		attr_accessor :x, :y, :radius
		
		def initialize(window, x, y, radius)
			@x = x
			@y = y
			@radius = radius
			@image = TexPlay.create_blank_image(window, MAX_RADIUS*2, MAX_RADIUS*2)
		end
		
		def update
			
		end
		
		def render
			@image.paint do
				circle CENTER, CENTER, @radius
			end
		end
		
		def draw
			@image.draw @x-CENTER, @y-CENTER, Z_INDEX
		end
		
		def clear_image
			@image = TexPlay.create_blank_image(window, MAX_RADIUS*2, MAX_RADIUS*2)
		end
	end
end
