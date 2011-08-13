#!/usr/bin/ruby
# Based on Fidgit by Spooner
# GPL v3 (see gpl.txt)
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widgets
	# Mix in which specifies behaviors for drawing different kinds of backgrounds
	module Background
		module Colored
			def init_background(color)
				@background_color = color # Gosu::Color format
				
				@verts = []
				@shape.each_vertex_absolute do |vertex|
					@verts << vertex
				end
			end
			
			def draw_background(z)
				@window.draw_quad	@verts[0].x, @verts[0].y, @background_color,
									@verts[1].x, @verts[1].y, @background_color,
									@verts[2].x, @verts[2].y, @background_color,
									@verts[3].x, @verts[3].y, @background_color, z
			end
		end
		
		module Image
			def init_background(img)
				@background_image = img
			end
			
			def draw_background(x,y,z)
				@background_image.draw x, y, z
			end
		end
	end
	
	class UI_Object
		attr_accessor :pz
		
		def initialize(window, z)
			@window = window
			@pz = z
		end
		
		def update
			
		end
		
		def draw
			
		end
		
		def position(type=:absolute)
			# Either :absolute
		end
		
		# position	:absolute, :to_bottom
		# 			:relative, widget, :to_top
		# align		:left/:right/:center/:top/:bottom
		# offset	10 #in px
	end
	
	# A roped-off zone where content can be rendered
	# Other widgets, as well as Gosu::Image instances, should
	# be able to exist within this context.
	class Div < UI_Object
		include Physics::TwoD_Support
		include Physics::TwoD_Support::Rect
		
		include Background::Colored
		
		def initialize(window, x, y, options={})
			options = 	{
							:background_color => Gosu::Color::BLUE,
							
							:z_index => 0,
							:align => :left,
							
							:width => 1,
							:height => 1,
							
							:padding_top => 0,
							:padding_bottom => 0,
							:padding_left => 0,
							:padding_right => 0
						}.merge! options
			
			super(window, options[:z_index])
			
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
		
		def draw(&block)
			draw_background 0
			
			#~ @window.translate render_x, render_y do
			block.call
			#~ end
		end
		
		#~ private
		
		def render_x
			self.px+@padding[:left]
		end
		
		def render_y
			self.py+@padding[:top]
		end
	end
	
	# Clickable button object
	class Button < UI_Object
		include Physics::TwoD_Support
		include Physics::TwoD_Support::Rect
		
		include Widgets::Background::Colored
		
		def initialize(window, x, y, options={}, &block)
			# The actual button event is processed within Chipmunk
			options =	{
							:z_index => 0,
							:relative => nil,
							
							:width => 1,
							:height => 1,
							
							:color => Gosu::Color::WHITE
						}.merge! options
			
			if options[:relative]
				options[:z_index] += options[:relative].pz + 1
			end
			
			super(window, options[:z_index])
			
			@block = block
			
			if options[:relative]
				x += options[:relative].render_x
				y += options[:relative].render_y
			end
			
			mass = 100
			moment = 100
			init_physics [x,y], options[:width], options[:height], mass, moment, :button
			
			init_background options[:color]
		end
		
		def update
			#~ puts self.px
		end
		
		def draw
			draw_background 0
		end
		
		def click_event
			@block.call
		end
	end
	
	# Similar to button, but not clickable
	class Label < UI_Object
		def initialize
			
		end
		
		def update
			
		end
		
		def draw
			
		end
	end
	
	# Used for loading bars and progress bars, as well as health bars etc
	class ProgressBar < UI_Object
		def initialize(percent)
			@percent = percent
			# percentage		100
			# background		Gosu::Image, none
			# background_color	Gosu::Color/0xaarrggbb, none
			# fill				Gosu::Color
		end
		
		def update
			
		end
		
		def draw
			
		end
		
		def percent=(arg)
			
		end
	end
	
	# Control a bunch of UI widgets as if they were one widget
	# Should be used as merely an abstraction
	class UI_Group
		attr_accessor :offset_x, :offset_y
		
		def initialize(offset_x, offset_y)
			@offset_x = offset_x
			@offset_y = offset_y
		end
	end
	
	class Box_Group < UI_Group
		def initialize(args={})
			args[:offset_x]
			args[:offset_y]
		end
	end
end
