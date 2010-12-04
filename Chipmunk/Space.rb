#!/usr/bin/ruby
require 'rubygems'
require 'chipmunk'

module CP
	class Space	
		def add(shape)
			add_body shape.body
			
			if shape.body.m == Float::INFINITY
				add_static_shape shape
			else
				add_shape shape
			end
		end
		
		def remove(shape)
			if shape.body.m == Float::INFINITY
				remove_static_shape shape
			else
				remove_shape shape
			end
		
			remove_body shape.body
		end
	end
end
