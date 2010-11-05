#!/usr/bin/ruby

module Gosu
	class Image
		def draw_centered(x, y, z, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
			self.draw(x-self.width/2*factor_x, y-self.height/2*factor_y, z, factor_x, factor_y, color, mode)
		end
	end
end
