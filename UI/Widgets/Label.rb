#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# Similar to button, but not clickable
	class Label < Div
		include Widget::Background::Colored
		
		attr_reader :text
		
		def initialize(window, x, y, options={})
			# The actual button event is processed within Chipmunk
			options = {
				:text_align => :center, #:center, :left, :right
				:vertical_align => :middle, # :bottom, :middle, :top
				
				:font => nil,	# Font object used to render text
				:text => nil,	# Text to be rendered on this label
				:color => Gosu::Color::WHITE
			}.merge! options
			
			super(window, x,y, options)
			
			if options[:text]
				# TODO: Throw exception if other necessary parameters are not set.
				@text = options[:text]
				
				
				if options[:font]
					@font = options[:font]
				else
					raise ArgumentError
				end
				
				
				if options[:color]
					@color = options[:color]
				else
					raise ArgumentError
				end
				
				text_align options[:text_align]
				vertical_align options[:vertical_align]
			end
		end
		
		def update
			
		end
		
		def draw
			draw_background @pz
			if @font
				@font.draw @text, @body.p.x+@font_offset_x, @body.p.y+@font_offset_y, @pz, 1,1, @color
			end
		end
		
		def text=(arg)
			update_align = (@text.length != arg.length)
			@text = arg
			
			if update_align
				text_align @text_align
				vertical_align @vertical_align
			end
		end
		
		private
		
		def text_align(align)
			@text_align = align
			
			@font_offset_x = case align
				when :left
					0
				when :center
					(@shape.width - @font.text_width(@text))/2
				when :right
					(@shape.width - @font.text_width(@text))
			end
		end
		
		def vertical_align(align)
			@vertical_align = align
			
			@font_offset_y = case align
				when :top
					0
				when :middle
					(@shape.height - @font.height)/2 + 2
					# Constant at the end may have to change
					# with font or platform
				when :bottom
					@shape.height - @font.height+5
					# Constant at the end may have to change
					# with font or platform
			end
		end
	end
end
