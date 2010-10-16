#!/usr/bin/ruby
require 'rubygems'
require 'chipmunk'

module CP
	class Space
		def add(shape, static=:nonstatic)
			add_body shape.body
			
			case static
				when :nonstatic
					add_shape shape
				when :static
					add_static_shape shape
			end
		end
		
		def remove(shape, static=:nonstatic)
			case static
				when :nonstatic
					remove_shape shape
				when :static
					remove_static_shape shape
			end
			
			remove_body shape.body
		end
	end
end
