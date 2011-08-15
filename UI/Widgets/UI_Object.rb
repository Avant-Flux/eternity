#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widget
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
end
