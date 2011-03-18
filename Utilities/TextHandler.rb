#!/usr/bin/ruby

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
end

# Managed text-based output classes.
class TextHandler
	def initialize
		
	end
end

# Define the area for text to be drawn, but not the borders etc.
class TextBox
	def initialize(pos=[0,0,0], width, height, font)
		@@font ||= Gosu::Font.new($window, "Trebuchet MS", 25)
		@font = font
		@font ||= @@font
		@i = 0
		move_to(pos[0], pos[1], pos[2])
		
		#Accept input for the width and height in pixels, but
		#store those values relative to character size.
		#Note: one character is roughly 0.625em
		em = @font.text_width("m")
		
		@width = (width / (em*0.625)).to_i			#Number of characters
		@height = (height / @font.height).to_i		#Number of lines
		
		#Make a queue to hold the lines to output.
		@output = [""]
	end
	
	# Update the state of the object.
	# Change which lines in the buffer should be drawn.
	def update
		if @output.size - @i > @height
			#~ @output.shift
			@i += 1
		end
	end
	
	# Render strings to the screen.
	def draw(options={})
		options[:z_offset] ||= 0
		
		iterations = [@height, @output.size].min
		
		iterations.times do |i|
			@font.draw @output[i+@i], @x, @y + i*@font.height, @z+options[:z_offset]
		end
	end
	
	def print(*args)
		args.each do |x|
			process_input x.to_s
		end
	end
	
	def printf(format_string, *args)
		print sprintf(format_string, *args)
	end
	
	def puts(*args)
		args.each do |x|
			print x.to_s, "\n"
		end
	end
	
	def p(*args)
		args.each do |x|
			puts x.inspect 
		end
	end
	
	def process_input(string)
		string.each_char do |c|
			if c == "\n"
				@output << ""
			else
				if @output.last.length <= @width
					@output.last << c
				else
					@output << c
				end
			end
		end
	end
	
	def move_to(x,y,z)
		@x = x
		@y = y
		@z = z
	end
end

class SpeechBubble
	TIMEOUT = 10000 #Time to wait before destroying this speech bubble
	REFRESH = 2000	#Time to wait before loading the next line.
	
	#Height and width measured in px
	BUBBLE_WIDTH = 300
	BUBBLE_HEIGHT = 200
	
	#Amount the bubble should float above the head of the entity.
	BUBBLE_RISE = 30
	
	@@all = {}
	
	def initialize(entity, text)
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
		
		@@all[hash] = self
	end
	
	class << self
		def update_all
			@@all.each_value do |i|
				i.update
			end
		end
		
		def draw_all
			@@all.each_value do |i|
				i.draw
			end
		end
	end
	
	
	def update
		if @destroy_timer.active?
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
		$window.draw_quad	@points[0].x, @points[0].y, @color, 
							@points[1].x, @points[0].y, @color, 
							@points[1].x, @points[1].y, 0xff880000, 
							@points[0].x, @points[1].y, 0xff880000, @entity.z
		
		# Draw triangle that points to character that is speaking
		$window.draw_triangle @points[2].x, @points[2].y, @color, 
							  @points[3].x, @points[3].y, @color, 
							  @points[4].x, @points[4].y, @color, @entity.z
		
		
		#Draw the actual text
		@textbox.draw :offset_z => @z_offset
	end
end
