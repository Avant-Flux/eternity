#!/usr/bin/ruby

class String
	# Return the last character in the string.
	def last
		self[length-1]
	end
end

class Numeric
	# Convert from points to ems.
	def to_em
		self / 12.0
	end
	
	# Convert from ems to points.
	def to_points
		self * 12
	end
end

class Point
	attr_accessor :x, :y
	
	def initialize(x=nil, y=nil)
		@x = x
		@y = y
	end
	
	def set(x, y)
		@x = x
		@y = y
	end
	
	#~ def
		#~ @x, @y
	#~ end
end

# Managed text-based output classes.
class TextHandler
	def initialize
		
	end
end

# Define the area for text to be drawn, but not the borders etc.
class TextBox
	def initialize(pos=[0,0,0], width, height, font)
		font ||= Gosu::Font.new($window, "Trebuchet MS", 25)
		@font = font
		
		#Accept input for the width and height in pixels, but
		#store those values relative to character size.
		#Note: one character is roughly 0.625em
		point = @font.height
		em = point/12.0
		
		@width = (width / (em*0.625)).to_i			#Number of characters
		@height = (height / @font.height).to_i		#Number of lines
		
		#Length of the output array should the height in lines of the text box
		@output = Array.new(@height)
		@update = false
	end
	
	# Update the state of the object.
	# Take input out of the buffer and place it into output to be rendered.
	def update
		if @update
			
			
			#If too much time has passed, clear the buffer
			
			
			
			#Parse out the buffer into lines that can be drawn to the screen.
		end
	end
	
	# Render strings to the screen.
	def draw
		@output.each do |string| #each_char
			@font.draw string, point1.x + 1, point1.y + 1, z.to_px + 5 +z_offset
		end
	end
	
	def puts(input)
		@update = true
		
		#Process new data into the buffer
		if @buffer.last == "."
			@buffer << "  "
		end
		@buffer << input
	end
end

class SpeechBubble
	TIMEOUT = 3000 #Time to wait before destroying this speech bubble
	#Height and width measured in px
	BUBBLE_WIDTH = 300
	BUBBLE_HEIGHT = 200
	
	# Create new point class
	@@all = {}
	
	def initialize(entity, text)
		@entity = entity
		
		@textbox = TextBox.new([@entity.x, @entity.y, @entity.z], 
								BUBBLE_WIDTH, BUBBLE_HEIGHT)
		
		@timer = Timer::After.new self, TIMEOUT do
			@@all.delete self.hash
		end
		
		
		@textbox.puts text
		
		
		
		# Create an array in which to store the points used to draw the bubble.
		@points = Array.new(7)
		@points.each do |i|
			i = Point.new
		end
				
		# Define color for text box
		@color = Gosu::Color::RED
		
		# The amount to offset the textbox from the entity speaking.
		@z_offset = 1000
		
		
		@@all[self.hash] = self
	end
	
	def update
		@textbox.update
		
		#Update the position at which to draw the bubble
		@points[0].set @entity.x.to_px - 60, @entity.y.to_px - @entity.height - 100
		@points[1].set @entity.x.to_px + 60, @entity.y.to_px - @entity.height - 100
		@points[2].set @entity.x.to_px - 60, @entity.y.to_px - @entity.height - 30
		@points[3].set @entity.x.to_px + 60, @entity.y.to_px - @entity.height - 30
		
		@points[4].set @entity.x.to_px - 60, @entity.y.to_px - @entity.height - 30
		@points[5].set @entity.x.to_px - 30, @entity.y.to_px - @entity.height - 30
		@points[6].set @entity.x.to_px, @entity.y.to_px - @entity.height
	end
	
	def draw
		#Draw the bubble for the text to be displayed in
		
		
		# Draw box to hold character text
		$window.draw_quad	@points[0].x, @points[0].y, @color, 
							@points[1].x, @points[1].y, @color, 
							@points[2].x, @points[2].y, @color, 
							@points[3].x, @points[3].y, @color, @entity.z+@z_offset
		
		# Draw triangle that points to character that is speaking
		$window.draw_triangle @points[4].x, @points[4].x, @color, 
							  @points[5].x, @points[5].x, @color, 
							  @points[6].x, @points[6].x, @color, @entity.z+@z_offset
		
		
		#Draw the actual text
		@textbox.draw :offset_z => @z_offset
	end
	
	#Generate a hash code.
	def hash
		@text.hash
	end
end
