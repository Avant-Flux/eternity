#!/usr/bin/ruby

module Gosu
	class Image
		alias :old_draw :draw
		alias :draw_UI :draw
		
		DEFAULT_OPTIONS = {
			:offset_x => 0,
			:offset_y => 0,
			:offset_z => 0,
			:factor_x => 1,
			:factor_y => 1,
			#~ options[:scale] => 1,
			:color => 0xffffffff,
			:mode => :default
		}
		
		def draw(x, y, z, zoom, options={})
			#Assume the coordinates are in units of meters from Chipmunk space.
			#Scale the x and y, and compute the z-index to pass to the old draw method.
			options = DEFAULT_OPTIONS.merge options
			
			
			if options[:opacity]
				# Assume opacity is specified as a value 0-255
				
				# This will overwrite the value specified in the color argument
				# or add one, if the higher order bits have not yet been set
				# Determine opacity bits
				#~ options[:opacity] = (255*options[:opacity]).to_i
				# Clear high-order bits
				options[:color] = 0x00ffffff & options[:color]
				# Set bits
				options[:color] = (options[:opacity] << 24) | options[:color]
			end
			
			if options[:scale]
				options[:factor_x] = options[:factor_y] = options[:scale]
			end
			
			if options[:factor_x]
				options[:factor_x] *= zoom
			else
				options[:factor_x] = zoom
			end
			
			if options[:factor_y]
				options[:factor_y] *= zoom
			else
				options[:factor_y] = zoom
			end
			
			options[:offset_x] = case options[:offset_x]
				when :centered
					self.width * options[:factor_x] / 2
				when :width
					self.width * options[:factor_x]
				else # Assume offset is in px
					options[:offset_x] * zoom
			end
			
			options[:offset_y] = case options[:offset_y]
				when :centered
					self.height * options[:factor_y] / 2
				when :height
					self.height * options[:factor_y]
				else # Assume offset is in px
					options[:offset_y] * zoom
			end
			
			x = x.to_px(zoom) - options[:offset_x]
			y = y.to_px(zoom) - options[:offset_y]
			z += options[:offset_z]
			
			old_draw(x,y,z, options[:factor_x], options[:factor_y], options[:color], options[:mode])
		end
		
		def draw_centered(x, y, z, zoom, options={})
			options[:offset_x] = options[:offset_y] = :centered
			draw(x,y,z, zoom, options)
		end
		
		def ==(arg)
			if arg.is_a? Gosu::Image
				return	self.width == arg.width &&
						self.height == arg.height &&
						self.to_blob == arg.to_blob
			else
				return false
			end
		end
	end
	
	class Font
		alias :old_draw :draw
		
		def draw(text, x,y,z, options={})
			options[:factor_x] ||= 1
			options[:factor_y] ||= 1
			options[:color] ||= 0xffffffff
			options[:mode] ||= :default
			
			old_draw	text, x,y,z, options[:factor_x], options[:factor_y], 
						options[:color], options[:mode]
		end
	end
	
	class Window
		alias :old_draw_line :draw_line
		def draw_line(x1, y1, c1, x2, y2, c2, z=0, mode=:default, zoom=nil)
			if zoom
				old_draw_line x1.to_px(zoom), y1.to_px(zoom), c1, x2.to_px(zoom), y2.to_px(zoom), c2, z, mode
			else
				old_draw_line x1, y1, c1, x2, y2, c2, z, mode
			end
		end
		
		alias :old_draw_quad :draw_quad
		def draw_quad(x1, y1, c1, x2, y2, c2, x3, y3, c3, x4, y4, c4, z=0, mode=:default, zoom=nil)
			if zoom
				old_draw_quad	x1.to_px(zoom), y1.to_px(zoom), c1, 
								x2.to_px(zoom), y2.to_px(zoom), c2, 
								x3.to_px(zoom), y3.to_px(zoom), c3, 
								x4.to_px(zoom), y4.to_px(zoom), c4, z, mode
			else
				old_draw_quad x1, y1, c1, x2, y2, c2, x3, y3, c3, x4, y4, c4, z, mode
			end
		end
		
		alias :old_draw_triangle :draw_triangle
		def draw_triangle(x1, y1, c1, x2, y2, c2, x3, y3, c3, z=0, mode=:default, zoom=nil)
			if zoom
				old_draw_triangle	x1.to_px(zoom), y1.to_px(zoom), c1, 
									x2.to_px(zoom), y2.to_px(zoom), c2, 
									x3.to_px(zoom), y3.to_px(zoom), c3, z, mode
			else
				old_draw_triangle x1, y1, c1, x2, y2, c2, x3, y3, c3, z, mode
			end
		end
	end
end
