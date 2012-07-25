#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# Clickable button object
	class Button < Label
		def initialize(window, options={}, &block)
			#~ options = 	{
				
			#~ }.merge! options
			
			super(window, options)
			
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
