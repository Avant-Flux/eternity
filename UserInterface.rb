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
	def initialize(window, player)#, a, b, cx, cy)
		@window = window
		@player = player
		@tracked = Array.new
		@ellipse = Ellipse.new(120, 80, @player.body.x, @player.body.y)
	end
	
	def track(entity)
		@tracked << Blip.new(@window, @player, entity)
	end
	
	def untrack(entity)
		#Remove from @tracked
		@tracked.delete_if {|x| x.entity == entity}
	end
	
	def update
		@tracked.each do |blip|
			blip.update
		end
	end
	
	def draw
		x = @player.body.x-IMAGE_WIDTH/2
		y = @player.body.y-IMAGE_HEIGHT/2-@player.body.z-@player.animations.height/6
		z = @player.body.z+10+@player.body.y
		
		@ellipse.draw x, y, z
		
		@tracked.each do |blip|
			blip.draw z
		end
	end
	
	private
	
	class Ellipse
		attr_accessor :a, :b, :cx, :cy
		
		def initialize(a, b, cx, cy, stroke_width=3)
			@a = a
			@b = b
			@cx = cx
			@cy = cy
			
			padding = stroke_width/2+10
			
			width = (@a+padding)*2
			height = (@b+padding)*2
			
			canvas = Magick::Image.new(width, height) do
				self.background_color = "transparent"
			end
			gc = Magick::Draw.new
			
			gc.stroke('red')
			gc.stroke_width(stroke_width)
			gc.fill_opacity(0)
			gc.ellipse(width/2,height/2, a,b, 0,360)
			
			gc.draw(canvas)
			@img = Gosu::Image.new(@window, canvas, false)
		end
		
		def update
			
		end
		
		def draw(x,y,z)
			@img.draw x, y, z
		end
	end
	
	class Blip
		MAX_RADIUS = 20
		CENTER = MAX_RADIUS/2
		
		attr_accessor :tracked
		
		def initialize(window, player, tracked_entity)
			@player = player
			@tracked = tracked_entity
			
			@vector = vector_between @tracked, @player
			@distance = @vector.length
			angle_to_tracked
			
			@x, @y = elliptical_projection
						
			@image = TexPlay.create_blank_image(window, MAX_RADIUS*2, MAX_RADIUS*2)
			render
		end
		
		def update
			new_vect = vector_between @tracked, @player
			new_dist = vector.length
			if new_dist != @distance
				@vector = new_vect
				@distance = new_dist
				clear_image
				render
			end
			@x, @y = elliptical_projection
		end
		
		def render
			@image.paint do
				circle CENTER, CENTER, @radius
			end
		end
		
		def draw(z_index=1)
			@image.draw @x-CENTER, @y-CENTER-z_index, z_index+@y
		end
		
		private
		
		def vector_between(arg1, arg2)
			x = arg1.body.x - arg2.body.x
			y = arg1.body.y - arg2.body.y
			CP::Vec2.new(x,y)
		end
		
		def angle_to_tracked
			#Returns angle in radians
			@vector.to_angle
		end
		
		def elliptical_projection
			#Calculate the corresponding position of a tracking blip for a given entity
			#The trig functions in ruby take the angle in radians
			angle = angle_to_tracked
			x = @player.body.x + RX*Math.cos(angle)
			y = @player.body.y + RY*Math.sin(angle)
			return x,y
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
