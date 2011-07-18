#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

module Widgets
	class UI_Object
		def initialize
			
		end
		
		# position	:absolute, :to_bottom
		# 			:relative, widget, :to_top
		# offset	10 #in px
	end
	
	class UI_Group
		def initialize
			
		end
	end
	
	# Clickable button object
	class Button < UI_Object
		def initialize
			
		end
	end
	
	# Used for loading bars, progress bars, etc
	class Bar < UI_Object
		def initialize
			
		end
	end
end
