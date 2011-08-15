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
			end
			
			mass = 100
			moment = 100
			init_physics [x,y], options[:width], options[:height], mass, moment, :button
			
			init_background options[:color]
		end
		
		def update
			
		end
		
		def draw
			draw_background @pz
			if @font
				@font.draw @text, px, py, pz
			end
		end
	end
end
