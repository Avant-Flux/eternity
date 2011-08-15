#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widget
	# Clickable button object
	class Button < Label
		def initialize(window, x, y, options={}, &block)
			super(window, x, y, options, &block)
			
			@block = block
		end
		
		def update
			super
		end
		
		def draw
			super
		end
		
		def click_event
			@block.call
		end
	end
end
