#!/usr/bin/ruby

class String
	#Return the last character in the string.
	def last
		self[length-1]
	end
end

class Numeric
	#Convert from points to ems.
	def to_em
		self * 0.0829872055543
	end
	
	#Convert from ems to points.
	def to_points
		self * 12.0500502857
	end
end

#Managed text-based output classes.
class TextHandler
	def initialize
		
	end
end

#Define the area for text to be drawn, but not the borders etc.
class TextBox
	def initialize(width, height, font=nil)
		@width = width
		@height = height
		
		@font = if font
			font
		else
			Gosu::Font.new($window, "Times New Roman", 25)
		end
		
		#Length of the output array should the height in lines of the text box
		@output = Array.new(@height / @font.height)
		@update = false
	end
	
	#Update the state of the object.
	#Take input out of the buffer and place it into output to be rendered.
	def update
		
		
		
		#If too much time has passed, clear the buffer
		
		
		
		#Parse out the buffer into lines that can be drawn to the screen.
		
	end
	
	#Render strings to the screen.
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
	
	@@all = {}
	
	def initialize(entity, text)
		@entity = entity
		@text = text
		@timer = Timer::After.new self, TIMEOUT do
			@@all.delete self.hash
		end
		@@all[self.hash] = self
	end
	
	def update
		
	end
	
	def draw
		
	end
	
	#Generate a hash code.
	def hash
		@text.hash
	end
end
