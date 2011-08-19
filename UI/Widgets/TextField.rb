#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widget
	# One line text input
	class TextField < TextBox
		def initialize(window, x,y, options={})
			options =	{
							:background_color => Gosu::Color::NONE,
							:editable => false	# Determines if the text can be edited or not
						}.merge! options
			
			unless options[:font]
				raise ArgumentError, "No font specified"
			end
			
			super window, x,y, options
			
			@text_input = nil
			
			# used to control blinking of the caret
			@blink = 0
		end
		
		def update
			@text = @text_input.text if @text_input
			if @font.text_width(@text) < width(:meters)
				text_align :left
			else
				text_align :right
			end
		end
		
		def draw
			@window.clip_to px,py, width(:meters), height(:meters) do
				super
				
				if @text_input
					reset_time = 30
					delay = 30
					
					text_width = @font.text_width(@text[0..@text_input.selection_start])
					
					if @blink >= reset_time && @blink < reset_time + delay
						@window.draw_line	px+text_width, py, @color,
											px+text_width, py+height(:meters), @color, @pz+3
					elsif @blink > reset_time + delay
						@blink = 0
					end
					@blink += 1
				end
			end
		end
		
		def on_click
			@window.text_input = Gosu::TextInput.new
			@text_input = @window.text_input
		end
	end
end
