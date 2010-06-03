#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.02.2010

require 'rubygems'
require 'gosu'
require 'chingu'

require 'chipmunk'
require 'ChipmunkInterfaceMod'

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
	def initialize(window, player)
		@player = player
		@tracked = Array.new
		@ellipse = TexPlay.create_blank_image(window, 500,500)
		@ellipse.paint do
			bezier[10,250,  250,50,  240,250]
		end
	end
	
	def track(entity)
		@tracked << entity
	end
	
	def untrack(entity)
		#Remove from @tracked
		@tracked.delete_if {|e| e == entity}
	end
	
	def update
		@tracked.each do |entity|
			
		end
	end
	
	def draw
		Blip.all.each {|b| b.draw}
		@ellipse.draw
	end
	
	private
	
	def add_blip(entity)
		
	end
	
	def remove_blip
		
	end
	
	def calculate_position
		
	end
	
	class Blip
		@@all = Array.new
		MAX_RADIUS = 20
		CENTER = MAX_RADIUS/2
		Z_INDEX = 1
		
		attr_accessor :x, :y, :radius
		
		def initialize(window, x, y, radius)
			@@all << self
			@x = x
			@y = y
			@radius = radius
			@image = TexPlay.create_blank_image(window, MAX_RADIUS*2, MAX_RADIUS*2)
		end
		
		class << self
			def all
				@@all
			end
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
