#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# Clickable button object
	class Button < Label
		def initialize(window, x, y, options={}, &block)
			#~ options = 	{
							
						#~ }.merge! options
			
			super(window, x, y, options, &block)
			
			@block = block
		end
		
		def update
			super
		end
		
		def draw
			super
		end
		
		def on_click
			@block.call
		end
	end
end
