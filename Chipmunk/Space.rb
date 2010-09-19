#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.18.2010
require 'rubygems'
require 'chipmunk'

module CP
	class Space
		def add(shape, static=:nonstatic)
			add_body shape.body
			
			if static == :nonstatic
				add_shape shape
			elsif static == :static
				add_static_shape shape
			end
		end
		
		def remove
			
		end
	end
end
