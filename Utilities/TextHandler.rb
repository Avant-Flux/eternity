#!/usr/bin/ruby

class String
	def last
		self[length-1]
	end
end

#Managed text-based output classes
class TextHandler
	def initialize
		
	end
end

#Define the area for text to be drawn, but not the borders etc.
class TextBox
	DEFAULT_FONT = Gosu::Font.new $window, "Times New Roman", 25

	def initialize(width, height, font=DEFAULT_FONT)
		@width = width
		@height = height
		@font = font
	end
	
	def update()
		if @buffer.last == "."
			@buffer << "  "
		end
		@buffer 
	end
	
	def draw
		@font.draw @output, point1.x + 1, point1.y + 1, z.to_px + 5 +z_offset
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
