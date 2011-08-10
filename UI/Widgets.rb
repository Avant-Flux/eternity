#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

module Widgets
	class UI_Object
		def initialize
			
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
	class RenderContext
		def initialize
			
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
