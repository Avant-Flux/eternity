#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 04.22.2010

require 'rubygems'
require 'chipmunk'

module CP
	class Space
		def add(arg)
			add_body arg.shape.body
			add_shape arg.shape
		end
	end
	
	class Space_3D
		attr_reader :xy, :xz
	
		def initialize
			@xy = Space.new
			@xz = Space.new
		end
	end
end
