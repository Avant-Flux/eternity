#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widget
	# A roped-off zone where content can be rendered
	# Other widgets, as well as Gosu::Image instances, should
	# be able to exist within this context.
	class Div < UI_Object
		include Physics::TwoD_Support
		include Physics::TwoD_Support::Rect
		
		include Background::Colored
		
		def initialize(window, x, y, options={})
			options = 	{
							:z_index => 0,
							:relative => nil,
							:align => :left,
							
							:width => 1,
							:height => 1,
							
							:background_color => Gosu::Color::BLUE,
							
							:padding_top => 0,
							:padding_bottom => 0,
							:padding_left => 0,
							:padding_right => 0
						}.merge! options
			
			if options[:relative]
				options[:z_index] += options[:relative].pz + 1
			end
			
			super(window, options[:z_index])
			
			if options[:relative]
				x += options[:relative].render_x
				y += options[:relative].render_y
			end
			
			mass = 100
			moment = 100
			init_physics	[x,y], options[:width], options[:height], mass, moment, :div
			
			init_background	options[:background_color]
			
			
			
			# Currently alignment is not taken into account
			@align = options[:align]
			
			@padding = {:top => options[:padding_top],
						:bottom => options[:padding_bottom],
						:left => options[:padding_left],
						:right => options[:padding_right]
						}
		end
		
		def update
			
		end
		
		def draw
			draw_background @pz
		end
		
		#~ private
		
		def render_x
			self.px+@padding[:left]
		end
		
		def render_y
			self.py+@padding[:top]
		end
	end
end
