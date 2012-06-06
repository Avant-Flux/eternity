#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# One line text input
	class TextField < TextBox
		attr_accessor :editable
		
		def initialize(window, x,y, options={})
			options =	{
							:background_color => Gosu::Color::NONE,
							:editable => true,	# Determines if the text can be edited or not
							:initial_temp_text => false # Initial text gets cleared on click
						}.merge! options
			
			unless options[:font]
				raise ArgumentError, "No font specified"
			end
			
			super window, x,y, options
			
			if options[:initial_temp_text]
				@temp = true
			end
			
			@editable = options[:editable]
			@active = false # Controls if the current textfield is being edited right now or not
			
			# used to control blinking of the caret
			@blink = 0
		end
		
		def update
			if @active
				@text = @window.text_input.text
			end
			
			if @font.text_width(@text) < width
				text_align :left
			else
				text_align :right
			end
		end
		
		def draw
			@window.clip_to @body.p.x,@body.p.y, @width, @height do
				super
				
				if @active
					reset_time = 30
					delay = 30
					
					text_width = @font.text_width(@text[0..@window.text_input.selection_start])
					
					if @blink >= reset_time && @blink < reset_time + delay
						@window.draw_line	px+text_width, py, @color,
											px+text_width, py+@height, @color, @pz+3
					elsif @blink > reset_time + delay
						@blink = 0
					end
					@blink += 1
				end
			end
		end
		
		def on_click
			@active = true
			@window.text_input = Gosu::TextInput.new
			if @temp
				@temp = false
			else
				@window.text_input.text = @text
			end
		end
		
		#~ def @text_input.filter(arg)
			#~ return /(\D*)(\d*)(\D*)/.match(arg)
		#~ end
		
		def on_lose_focus
			@active = false
			@window.text_input = nil
		end
		
		def text=(text)
			@text = text
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
