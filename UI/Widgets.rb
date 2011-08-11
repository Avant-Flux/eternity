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
				@shape.each_vertex do |vertex|
					@verts << vertex
				end
			end
			
			def draw_background(x,y,z)
				@window.draw_quad	@verts[0].x+x, @verts[0].y+y, @background_color,
									@verts[1].x+x, @verts[1].y+y, @background_color,
									@verts[2].x+x, @verts[2].y+y, @background_color,
									@verts[3].x+x, @verts[3].y+y, @background_color, z
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
		def initialize(shape)
			@shape = shape
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
	class Div
		include Physics::TwoD_Support
		include Physics::TwoD_Support::Rect
		
		include Background::Colored
		
		def initialize(window, pos, width, height, options={})
			@window = window
			
			options = {:background_color => Gosu::Color::BLUE,
						
						:padding_top => 0,
						:padding_bottom => 0,
						:padding_left => 0,
						:padding_right => 0
						}.merge! options
			
			mass = 100
			moment = 100
			collision_type = :div
			init_physics	pos, width, height, mass, moment, :div
			
			init_background	options[:background_color]
			
			@padding = {:top => options[:padding_top],
						:bottom => options[:padding_bottom],
						:left => options[:padding_left],
						:right => options[:padding_right]
						}
			#~ @render_x = pos[0] + options[:padding_left]
			#~ @render_y = pos[1] + options[:padding_top]
			#~ @render_width = width - options[:padding_left] - options[:padding_right]
			#~ @render_height = height - options[:padding_top] - options[:padding_bottom]
			
			@children = []
		end
		
		def update
			
		end
		
		def draw(&block)
			draw_background self.px, self.py, 0
			
			@window.translate self.px+@padding[:left], self.py+@padding[:top] do
				block.call
			end
		end
	end
	
	# Clickable button object
	class Button < UI_Object
		def initialize
			
		end
		
		def update
			
		end
		
		def draw
			
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
