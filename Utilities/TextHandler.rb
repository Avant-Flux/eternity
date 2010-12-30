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
	
	@@all = {}
	
	def initialize(entity, text)
		@entity = entity
		
		@textbox = TextBox.new([@entity.x, @entity.y, @entity.z], 
								BUBBLE_WIDTH, BUBBLE_HEIGHT)
		
		@timer = Timer::After.new self, TIMEOUT do
			@@all.delete self.hash
		end
		
		@textbox.puts text
		
		
		# Create new point class
		point = Struct.new(:x,:y)
		
		# Store each point of the text box in an ordered pair (x,y)
		point1 = point.new x.to_px - 60, y.to_px - height - 100
		point2 = point.new x.to_px + 60, y.to_px - height - 100
		point3 = point.new x.to_px - 60, y.to_px - height - 30
		point4 = point.new x.to_px + 60, y.to_px - height - 30
		
		# Define color for text box
		color = Gosu::Color::RED
		
		z_offset = 1000
		
		# Draw box to hold character text

		$window.draw_quad(point1.x, point1.y, color, 
						   point2.x, point2.y, color, 
						   point3.x, point3.y, color, 
						   point4.x, point4.y, color, z+z_offset)
		
		# Draw triangle that points to character that is speaking
		$window.draw_triangle x.to_px - 60, y.to_px - height - 30, color, 
							  x.to_px - 30, y.to_px - height - 30, color, 
							  x.to_px, y.to_px - height, color, z+z_offset
		
		
		@@all[self.hash] = self
		
		
		
	end
	
	def update
		@textbox.update
	end
	
	def draw
		@textbox.draw
	end
	
	#Generate a hash code.
	def hash
		@text.hash
	end
end
