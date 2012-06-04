#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# Similar to Label, but is attached to another widget.
	# Appears only on mouseover of the attached widget.
	class Tooltip < Label
		def initialize
			
		end
	end
end
