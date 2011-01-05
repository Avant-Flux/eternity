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
	def initialize(pos=[0,0,0], width, height)
		@font = Gosu::Font.new($window, "Trebuchet MS", 25)
		
		move pos
		
		#Accept input for the width and height in pixels, but
		#store those values relative to character size.
		#Note: one character is roughly 0.625em
		#~ point = @font.height
		#~ em = point/12.0
		em = @font.text_width("m")
		@line_height = (@font.height*1).to_i
		
		@width = (width / (em*0.625)).to_i			#Number of characters
		@height = (height / @line_height).to_i		#Number of lines
		
		#Length of the output array should the height in lines of the text box
		@output = []
		@update = false
		
		#Create input buffer
		@input_buffer = ""
		@output_buffer = []
	end
	
	# Update the state of the object.
	# Take input out of the buffer and place it into output to be rendered.
	def update
		#~ if @update
			puts "start update"
			
			#If too much time has passed, clear the buffer
			
			
			
			#Place as many lines as possible into the output queue.
			#~ (@height).times do
				#~ @output << @output_buffer.shift
			#~ end
			
			#Set @update to false if and only if the output buffer is empty.
			#If the output buffer is not empty, more text needs to be moved into
			#the output queue from the output buffer on the next update.
			#~ @update = false if @output_buffer.empty?
		#~ end
	end
	
	# Render strings to the screen.
	def draw(options={})
		options[:z_offset] ||= 0
		#~ p @output
		#~ @output.each_with_index do |string, i| #each_char
			#~ x = @x + i*@line_height
			#~ y = @y + i*@line_height
			#~ z = @z + options[:z_offset]
			#~ @font.draw "hello world", @x, y, z
		#~ end
		
		output = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin eleifend lacus quis dolor semper a faucibus nulla pharetra. Fusce venenatis posuere libero, aliquam malesuada lectus tempus nec. Donec vel dapibus magna. Quisque iaculis enim nec eros pharetra placerat. Sed enim metus, lobortis sed varius quis, interdum ac libero. Vivamus risus."
		
		@height.times do |i|
			start = (i*(@width+1))
			stop = start+@width
			
			y= @y + i*@line_height
			
			@font.draw output[start..stop], @x, y, @z, options
		end
	end
	
	def puts(input)
		#~ @update = true
		#~ 
		#~ #Process new data into the buffer
		#~ if @input_buffer.last == "."
			#~ @input_buffer << "  "
		#~ end
		#~ puts input
		#~ @input_buffer << input
		#~ 
		#~ puts @input_buffer
		#~ 
		#~ #Parse out the buffer into lines that can be drawn to the screen.
			#~ while @input_buffer.length > @width
				#~ puts "start parsing"
				#~ #Place a chunk of input into the output buffer
				#~ @output_buffer << @input_buffer[0..(@width-1)]
				#~ 
				#~ #Remove the chunk from the input buffer
				#~ @input_buffer = @input_buffer[@width..@input_buffer.length-1]
			#~ end
			#~ unless @input_buffer.empty?
				#~ #Place the last portion of input in the output buffer.
				#~ #This last portion should be shorter than the maximum
				#~ #line width at this point.
				#~ @output_buffer << @input_buffer
				#~ @input_buffer.clear
			#~ end
	end
	
	def move(pos)
		@x = pos[0]
		@y = pos[1]
		@z = pos[2]
	end
end

class SpeechBubble
	TIMEOUT = 10000 #Time to wait before destroying this speech bubble
	#Height and width measured in px
	BUBBLE_WIDTH = 300
	BUBBLE_HEIGHT = 200
	
	#Amount the bubble should float above the head of the entity.
	BUBBLE_RISE = 30
	
	# Create new point class
	@@all = {}
	
	def initialize(entity, text)
		@entity = entity
		
		@textbox = TextBox.new([0,0,0], 
								BUBBLE_WIDTH, BUBBLE_HEIGHT)
		
		@timer = Timer::After.new self, TIMEOUT do
			@@all.delete self.hash
		end
		

		
		# Create an array in which to store the points used to draw the bubble.
		@points = Array.new(5)
		@points.each_with_index do |point,i|
			@points[i] = Point.new
		end
				
		# Define color for bubble.
		@color = Gosu::Color::RED
		
		# The amount to offset the textbox from the entity speaking.
		@z_offset = 1000
		
		
		@@all[self.hash] = self
	end
	
	class << self
		def update_all
			@@all.each_value {|i| i.update}
		end
		
		def draw_all
			@@all.each_value {|i| i.draw}
		end
	end
	
	def update
		
		
		#Update the position at which to draw the bubble
		
		#Draw the box portion
		
		#Bottom Left
		@points[0].set @entity.x.to_px, @entity.y.to_px - @entity.height - BUBBLE_RISE
		#Top Right
		@points[1].set @points[0].x + BUBBLE_WIDTH, @points[0].y - BUBBLE_HEIGHT
		
		@points[2].set @entity.x.to_px - 60, @entity.y.to_px - @entity.height - 30
		@points[3].set @entity.x.to_px - 30, @entity.y.to_px - @entity.height - 30
		@points[4].set @entity.x.to_px, @entity.y.to_px - @entity.height
		
		
		
		@textbox.update
		@textbox.move [@points[0].x, @points[1].y, @entity.z]
	end
	
	def draw
		#Draw the bubble for the text to be displayed in
		
		
		# Draw box to hold character text
		#Specify points in counter clockwise order starting from bottom left.
		$window.draw_quad	@points[0].x, @points[0].y, @color, 
							@points[1].x, @points[0].y, @color, 
							@points[1].x, @points[1].y, @color, 
							@points[0].x, @points[1].y, @color, @entity.z
		
		# Draw triangle that points to character that is speaking
		$window.draw_triangle @points[2].x, @points[2].x, @color, 
							  @points[3].x, @points[3].x, @color, 
							  @points[4].x, @points[4].x, @color, @entity.z
		
		
		#Draw the actual text
		@textbox.draw :offset_z => @z_offset
	end
	
	#Generate a hash code.
	def hash
		@text.hash
	end
end
