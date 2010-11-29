#!/usr/bin/ruby

module Gosu
	class Image
		alias :old_draw :draw
		alias :draw_UI :draw
		
		#Completion of this method will require a rewrite of draw_centered
		def draw(x, y, z, options={})
			#Assume the coordinates are in units of meters from Chipmunk space.
			#Scale the x and y, and compute the z-index to pass to the old draw method.
			
			options[:offset_x] ||= 0
			options[:offset_y] ||= 0
			options[:factor_x] ||= 1
			options[:factor_y] ||= 1
			options[:color] ||= 0xffffffff
			options[:mode] ||= :default
			
			options[:offset_x] = case options[:offset_x]
				when :centered
					self.width * options[:factor_x] / 2
				when :width
					self.width
				else
					options[:offset_x]
			end
			
			options[:offset_y] = case options[:offset_y]
				when :centered
					self.height * options[:factor_y] / 2
				when :height
					self.height
				else
					options[:offset_y]
			end
						
			render_x = x.to_px - options[:offset_x]
			render_y = y.to_px - z.to_px - options[:offset_y]
			z_index = z + y
			
			old_draw(render_x, render_y, z_index, 
					options[:factor_x], options[:factor_y], 
					options[:color], options[:mode])
		end
		
		def draw_centered(x, y, z, options={})
			options[:offset_x] = options[:offset_y] = :centered
			draw(x,y,z, options)
		end
	end
end
