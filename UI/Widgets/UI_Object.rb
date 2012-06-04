#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	class UI_Object
		attr_accessor :pz
		
		def initialize(window, z)
			@window = window
			@pz = z
			@children = []
		end
		
		def update
			
		end
		
		def draw
			
		end
		
		def move_x(x)
			self.px += x
			@children.each do |child|
				child.px += x
			end
		end
		
		def move_y(y)
			self.py += y
			@children.each do |child|
				child.py += y
			end
		end
		
		def position(type=:absolute)
			# Either :absolute
		end
		
		# position	:absolute, :to_bottom
		# 			:relative, widget, :to_top
		# align		:left/:right/:center/:top/:bottom
		# offset	10 #in px
		
		def on_click
		end
		
		def on_lose_focus
		end
	end
end
