#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 04.20.2010
 
module CP
	class Space
		def add(arg)
			add_body arg.shape.body
			add_shape arg.shape
		end
	end
end
