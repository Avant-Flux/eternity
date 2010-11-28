#!/usr/bin/ruby

module Gosu
	class Image
		#~ alias :old_draw, :draw
		#~ 
		#~ #Completion of this method will require a rewrite of draw_centered
		#~ def draw(x, y, z, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
			#~ #Assume the coordinates are in units of meters from Chipmunk space.
			#~ #Scale the x and y, and compute the z-index to pass to the old draw method.
			#~ old_draw(x,y,z, factor_x,factor_y, color, mode)
		#~ end
	
		def draw_centered(x, y, z, factor_x=1, factor_y=1, color=0xffffffff, mode=:default)
			self.draw(x-self.width/2*factor_x, y-self.height/2*factor_y, z, factor_x, factor_y, color, mode)
		end
	end
end
