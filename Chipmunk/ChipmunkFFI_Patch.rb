#!/usr/bin/ruby

module CP
	class Space
		 def bb_query(bb, layers, group, &block)
			query_proc = Proc.new do | |
				block.call
			end
	    
			CP.cpSpaceBBQuery(@struct.pointer, bb.struct, layers, group, nil)
	    end
	end
end

