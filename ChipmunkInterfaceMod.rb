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
		attr_reader :xy, :xz, :dt
	
		def initialize(dt=(1.0/60.0))
			@dt = dt
			
			@xy = Space.new
			@xz = Space.new
		end
		
		def step
			@xy.step(@dt)
			@xz.step(@dt)
		end
	end
end
