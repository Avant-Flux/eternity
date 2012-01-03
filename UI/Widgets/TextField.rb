#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widget
	# One line text input
	class TextField < TextBox
		attr_accessor :editable
		
		def initialize(window, x,y, options={})
			options =	{
							:background_color => Gosu::Color::NONE,
							:editable => true	# Determines if the text can be edited or not
						}.merge! options
			
			unless options[:font]
				raise ArgumentError, "No font specified"
			end
			
			super window, x,y, options
			
			@editable = options[:editable]
			@text_input = nil
			
			# used to control blinking of the caret
			@blink = 0
		end
		
		def update
			if @text_input
				@text = @text_input.text
			end
			
			if @font.text_width(@text) < width(:meters)
				text_align :left
			else
				text_align :right
			end
			
			unless @editable
				reset
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
			@editable = true
			@window.text_input = Gosu::TextInput.new
			@window.text_input.text = @text
			@text_input = @window.text_input
		end
		
		#~ def @text_input.filter(arg)
			#~ return /(\D*)(\d*)(\D*)/.match(arg)
		#~ end
		
		def on_lose_focus
			reset
		end
		
		def reset
			if @text_input
				@text_input = @window.text_input = nil
			end
			#~ @text = nil
		end
	end
end

#~ module Gosu
	#~ class TextInput
		#~ def filter(text_in)
			#~ 
			#~ return /(\D*)(\d*)(\D*)/.match(text_in)[2]
		#~ end
	#~ end
#~ end
