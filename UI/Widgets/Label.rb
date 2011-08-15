#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widget
	# Similar to button, but not clickable
	class Label < UI_Object
		include Physics::TwoD_Support
		include Physics::TwoD_Support::Rect
		
		include Widget::Background::Colored
		
		def initialize(window, x, y, options={})
			# The actual button event is processed within Chipmunk
			options =	{
							:z_index => 0,
							:relative => nil,
							
							:width => 1,
							:height => 1,
							
							:background_color => Gosu::Color::NONE,
							
							:text_align => :center, #:center, :left, :right
							:vertical_align => :middle, # :bottom, :middle, :top
							
							:font => nil,	# Font object used to render text
							:text => nil,	# Text to be rendered on this label
							:color => Gosu::Color::WHITE
						}.merge! options
			
			if options[:relative]
				options[:z_index] += options[:relative].pz + 1
			end
			
			super(window, options[:z_index])
			
			if options[:relative]
				x += options[:relative].render_x
				y += options[:relative].render_y
			end
			
			if options[:text]
				@text = options[:text]
				@font = options[:font]
				@color = options[:color]
				
				@font_offset_x =	case options[:text_align]
										when :left
											0
										when :center
											(options[:width] - @font.text_width(@text))/2
										when :right
											(options[:width] - @font.text_width(@text))
									end
				@font_offset_y =	case options[:vertical_align]
										when :top
											0
										when :middle
											(options[:height] - @font.height)/2 + 2
											# Constant at the end may have to change
											# with font or platform
										when :bottom
											options[:height] - @font.height+5
											# Constant at the end may have to change
											# with font or platform
									end
			end
			
			mass = 100
			moment = 100
			init_physics [x,y], options[:width], options[:height], mass, moment, :button
			
			init_background options[:background_color]
		end
		
		def update
			
		end
		
		def draw
			draw_background @pz
			if @font
				@font.draw @text, px+@font_offset_x, py+@font_offset_y, pz, :color => @color
			end
		end
	end
end
