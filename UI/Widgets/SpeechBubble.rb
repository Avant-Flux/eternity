#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	class SpeechBubble < TextArea
		TIMEOUT = 10000 #Time to wait before destroying this speech bubble
		REFRESH = 2000	#Time to wait before loading the next line.
		
		#Height and width measured in px
		BUBBLE_WIDTH = 300
		BUBBLE_HEIGHT = 200
		
		#Amount the bubble should float above the head of the entity.
		BUBBLE_RISE = 30
		
		def initialize(window, entity, text)
			@window
			@entity = entity
			
			@textbox = TextBox.new([0,0,0], BUBBLE_WIDTH, BUBBLE_HEIGHT)
			@textbox.puts text
			
			@destroy_timer = Timer::After.new self, TIMEOUT
			@update_timer = Timer::After.new self, REFRESH, true
	
			
			# Create an array in which to store the points used to draw the bubble.
			@points = Array.new(5)
			@points.each_with_index do |point,i|
				@points[i] = Point.new
			end
					
			# Define color for bubble.
			@color = Gosu::Color::RED
			
			# The amount to offset the textbox from the entity speaking.
			@z_offset = 1000
		end
		
		def update
			if @destroy_timer.active?
				# Instead of linking to a hash with all speech bubbles
				# should link to the related  --game object--  no
				# Link only to CP space
				# Thus, when removed from space, the speech bubble will be marked for GC
				@@all.delete self.hash
			end
			if @update_timer.active?
				@textbox.update
			end
	
			#Update the position at which to draw the bubble
			
			#Draw the box portion
			#Bottom Left
			@points[0].set @entity.x.to_px, @entity.y.to_px - @entity.height - BUBBLE_RISE
			#Top Right
			@points[1].set @points[0].x + BUBBLE_WIDTH, @points[0].y - BUBBLE_HEIGHT
			
			#Draw the arrow portion
			#Top left
			@points[2].set @points[0].x, @points[0].y
			#Top right
			@points[3].set @points[2].x + 30, @points[2].y
			#Bottom
			@points[4].set @entity.x.to_px, @entity.y.to_px - @entity.height
			
			
			
			@textbox.move_to = @points[0].x, @points[1].y, @entity.z
		end
		
		def draw
			#Use $window.clip_to (x, y, w, h, &drawing_code)
			#to help implement smooth text scrolling
		
			#Draw the bubble for the text to be displayed in
			
			# Draw box to hold character text
			#Specify points in counter clockwise order starting from bottom left.
			@window.draw_quad	@points[0].x, @points[0].y, @color, 
								@points[1].x, @points[0].y, @color, 
								@points[1].x, @points[1].y, 0xff880000, 
								@points[0].x, @points[1].y, 0xff880000, @entity.z
			
			# Draw triangle that points to character that is speaking
			@window.draw_triangle @points[2].x, @points[2].y, @color, 
								  @points[3].x, @points[3].y, @color, 
								  @points[4].x, @points[4].y, @color, @entity.z
			
			
			#Draw the actual text
			@textbox.draw :offset_z => @z_offset
		end
	end
end
