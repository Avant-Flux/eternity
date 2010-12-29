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
