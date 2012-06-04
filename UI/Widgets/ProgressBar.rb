#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
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
end
