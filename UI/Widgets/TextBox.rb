#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widget
	# Parent of TextField and TextArea
	# Define the area for text to be drawn, but not the borders etc.
	class TextBox < UI_Object
		def initialize(window, pos=[0,0,0], width, height, font, editable=false)
			@font = font || Gosu::Font.new(window, "Trebuchet MS", 25)
			@i = 0
			move_to pos
			
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
		
		def move_to(pos)
			@x = pos[0]
			@y = pos[1]
			@z = pos[2]
		end
	end
end
