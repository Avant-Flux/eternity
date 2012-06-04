#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# A roped-off zone where content can be rendered
	# Other widgets, as well as Gosu::Image instances, should
	# be able to exist within this context.
	class ScrollingDiv < Div
		def initialize(window, x, y, options={})
			super window, x, y, options
		end
		
		def update
			super
		end
		
		def draw
			super
		end
	end
end
