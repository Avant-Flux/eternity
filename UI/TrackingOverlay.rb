#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require 'RMagick'

#This class renders the overlay which shows the position of tracked entities
#	In order to render this effect is psudo-perspective without a global perspective warp,
#	render the tracking blips along an ellipse which simulates a circle in perspective.
#
#	Calculate an ellipse and project the rendering of the blip onto it.
#	Calculate the position of the blip by getting the angle between the player and the entity
#	to be tracked.
#
#	Calculate the position of all elements in the tracking overlay, then displace by a certain
#	amount to allow the overlay to be rendered at the level of the Player's waist instead of
#	the normal location at foot-level.
module UI
	module Overlay
		class Tracking
			def initialize(player, a=4, b=2)
				@player = player
				@tracked = Array.new
				@ellipse = Ellipse.new(@player, a, b)
			end
			
			def track(entity)
				@tracked << $art_manager.new_blip(@player, entity, @ellipse)
			end
			
			def untrack(entity)
				#Remove from @tracked
				@tracked.delete_if {|x| x.entity == entity}
			end
			
			def update
				@ellipse.update
				
				@tracked.each do |blip|
					blip.update
				end
			end
			
			def draw
				@ellipse.draw
				
				@tracked.each do |blip|
					blip.draw
				end
			end
		end
		
		class Ellipse
			#~ Dimensions for the Ellipse should be given in meters.
			#~ The initial rendering of the Ellipse will be done using the initial conversion 
			#~ 		rate between pixels and meters.  subsequent resizing will be done using
			#~ 		OpenGL to scale the generated sprite.
			#~ Arguments are accepted with units of meters, but are immediately converted to
			#~ 		pixels.  This is because the generation of the ellipse requires pixel
			#~ 		dimensions.

			attr_accessor :a, :b, :cx, :cy
			attr_reader :x, :y, :z
			
			def initialize(player, a, b, stroke_width=3)
				@player = player
				@a = a
				@b = b
				
				a = a.to_px
				b = b.to_px
				
				padding = stroke_width/2+10
				
				width = (a+padding)*2
				height = (b+padding)*2
				
				canvas = Magick::Image.new(width, height) do
					self.background_color = "transparent"
				end
				gc = Magick::Draw.new
				
				gc.stroke('red')
				gc.stroke_width(stroke_width)
				gc.fill_opacity(0)
				gc.ellipse(width/2,height/2, a,b, 0,360)
				
				gc.draw(canvas)
				@img = Gosu::Image.new($window, canvas, false)
			end
			
			def update
				
			end
			
			def draw
				@img.draw_centered @player.x, @player.y, @player.z
			end
		end
		
		class Blip
			MAX_RADIUS = 25
			MIN_SCALE = 0.1
			
			attr_accessor :tracked, :player
			
			def initialize(player, tracked_entity, circle, ellipse)
				@player = player
				@tracked = tracked_entity
				@circle = circle
				@ellipse = ellipse
				
				@vector = CP::Vec2.new(0,0)	
				@distance = 1
				
				elliptical_projection
				scale
			end
			
			def update
				distance @tracked, @player
				scale
				elliptical_projection
			end
			
			def draw
				@circle.draw_centered @x, @y, @player.z, :scale => @scale, :color => 0xFFFF0000
			end
			
			private
		
			def distance(arg1, arg2)
				@vector.x = arg1.shape.x - arg2.shape.x
				@vector.y = arg1.shape.y - arg2.shape.y
				@distance = @vector.length
			end
				
			def elliptical_projection
				#Calculate the corresponding position of a tracking blip for a given entity
				#The trig functions in ruby take the angle in radians
				angle = @vector.to_angle #Returns the angle to the tracked Entity in radians
				
				@x = @player.x + @ellipse.a*Math.cos(angle)
				@y = @player.y + @ellipse.b*Math.sin(angle)
			end
			
			def scale
				constant = 120
				#~ r = ((constant/@distance)*Math.sqrt(2/Math::PI)).ceil
				
				#~ max_factor = 1
				#~ min_factor = 0.1
				#~ 
				#~ max_distance = 120
				#~ min_distance = 3
				#~ puts @distance
				#~ if @distance >= max_distance
								#~ @scale = max_factor
							#~ elsif @distance.between? max_distance, min_distance
								#~ x = @distance - min_distance
								#~ @scale = @distance / 3.0
							#~ elsif @distance <= min_distance
								#~ @scale = min_factor
							#~ end
				#~ puts 1
				#~ puts @distance.class
				#~ puts @distance
				@scale = constant/(@distance**2)
				
				#Set maximum and minimum values for @scale
				@scale = 1 if @scale > 1
				@scale = MIN_SCALE if @scale < MIN_SCALE
			end
		end
	end
end
