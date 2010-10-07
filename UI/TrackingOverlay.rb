#!/usr/bin/ruby
#~ Name: Jason

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
#	the normal location at foot-level.'
module UI
	module Overlay
		class Tracking
			def initialize(window, player, a=4, b=2)
				@window = window
				@player = player
				@tracked = Array.new
				@ellipse = Ellipse.new(@window, @player, a, b, 
										@player.shape.x, @player.shape.y)
			end
			
			def track(entity)
				@tracked << Blip.new(@window, @player, entity, @ellipse)
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
				
				def initialize(window, player, a, b, cx, cy, stroke_width=3)
					@window = window
					@player = player
					@a = a.to_px
					@b = b.to_px
					@cx = cx.to_px
					@cy = cy.to_px
					
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
					gc.ellipse(width/2,height/2, @a,@b, 0,360)
					
					gc.draw(canvas)
					@img = Gosu::Image.new(@window, canvas, false)
				end
				
				def update
					@cx = @player.shape.x.to_px
					@cy = @player.shape.y.to_px
					
					#Adjust x and y to compensate for storing the coordinates of the center point
					#	when the image is drawn from the corner.
					@x = @cx-@img.width/2
					@y = @cy-@img.height/2
					@z = @player.shape.z.to_px+y
					
					#Move the y-coordinate to compensate for the player's z coordinate and elevation
					@y -= @player.shape.z.to_px#-@player.animations.height/5
				end
				
				def draw
					@img.draw @x, @y, @z
				end
			end
			
			class Blip
				MAX_RADIUS = 25
				CENTER = MAX_RADIUS
				
				attr_accessor :tracked, :player
				
				def initialize(window, player, tracked_entity, ellipse)
					@window = window
					@player = player
					@tracked = tracked_entity
					@ellipse = ellipse
					
					@vector = vector_between @tracked, @player
					@distance = @vector.length.ceil
					
					@x, @y = elliptical_projection
								
					clear_image
					@radius = 10
					render
				end
				
				def update
					new_vect = vector_between @tracked, @player
					new_dist = new_vect.length.ceil
					if new_dist != @distance
						@vector = new_vect
						@distance = new_dist
						render
					end
					@x, @y = elliptical_projection
				end
				
				def draw
					@image.draw @x-CENTER, @y-CENTER-@player.shape.z.to_px, @ellipse.z
					#~ puts "#{@distance}   (#{@x}, #{@y})"
				end
				
				private
				
				def clear_image
					@image = TexPlay.create_blank_image(@window, MAX_RADIUS*2, MAX_RADIUS*2)
				end
				
				def render
					radius = calculate_radius
					#~ puts radius
					if radius > MAX_RADIUS
						radius = MAX_RADIUS
					elsif radius < 1
						radius = 1
					end
					
					if radius > @radius
						@radius = radius
						@image.circle CENTER, CENTER, @radius, :fill => true, :color => :red
					elsif radius < @radius
						@radius = radius
						clear_image
						@image.circle CENTER, CENTER, @radius, :fill => true, :color => :red
					else#radius == @radius
						nil
					end
				end
			
				def vector_between(arg1, arg2)
					x = arg1.shape.x - arg2.shape.x
					y = arg1.shape.y - arg2.shape.y
					CP::Vec2.new(x,y)
				end
					
				def elliptical_projection
					#Calculate the corresponding position of a tracking blip for a given entity
					#The trig functions in ruby take the angle in radians
					angle = @vector.to_angle #Returns the angle to the tracked Entity in radians
					
					#~ The distances here should already be in pixels, as that is how the data
					#~ 		is stored in the ellipse.
					x = @ellipse.cx + @ellipse.a*Math.cos(angle)
					y = @ellipse.cy + @ellipse.b*Math.sin(angle)
					return x,y
				end
				
				
				def calculate_radius
					constant = 120
					((constant/@distance)*Math.sqrt(2/Math::PI)).ceil
				end
			end
		end
	end
end
