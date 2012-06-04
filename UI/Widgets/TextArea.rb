#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# Multi-line text input
	class TextArea < TextBox
		def initialize(window, x,y, options={})
			options =	{
							:background_color => Gosu::Color::NONE,
							:editable => false	# Determines if the text can be edited or not
						}.merge! options
			
			unless options[:font]
				raise ArgumentError, "No font specified"
			end
			
			super window, x, y, options
			
			#~ 
			#~ @i = 0
			#~ move_to pos
			#~ 
			#~ #Accept input for the width and height in pixels, but
			#~ #store those values relative to character size.
			#~ #Note: one character is roughly 0.625em
			#~ 
			#~ # Number of characters which can be displayed on one line
			#~ @text_width =	if options[:width_units] == :em
								#~ options[:width]
							#~ else
								em = @font.text_width("m")
								#~ (self.width(:meters) / (em*0.625)).to_i
							#~ end
			#~ 
			#~ # Height in lines
			#~ @text_height = (self.height(:meters) / @font.height).to_i
			#~ 
			#~ #Make a queue to hold the lines to output.
			#~ @output = [""]
		end
		
		def update
			
		end
		
		def draw
			
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
		#~ def draw(options={})
			#~ draw_background # Really only here for debug purposes
			#~ 
			#~ options[:z_offset] ||= 0
			#~ 
			#~ iterations = [@height, @output.size].min
			#~ 
			#~ iterations.times do |i|
				#~ @font.draw @output[i+@i], @x, @y + i*@font.height, @z+options[:z_offset]
			#~ end
		#~ end
		
		# Set caret position based on click input
		def on_click
			# If editable, set carat position on click
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
		
		# Return stored string data
		def gets
			
		end
		
		def move_to(pos)
			@x = pos[0]
			@y = pos[1]
			@z = pos[2]
		end
	end
end
