#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.28.2010
 
module Wireframe
	class Circle
		def initialize
			
		end
		
		def update
			
		end
		
		def draw
			
		end
	end

	class Rect
		def initialize(window, shape)
			@window = window
			@shape = shape
		end
		
		def update
			
		end
		
		def draw
			color = Gosu::Color::BLACK
			side_thickness = 10
			z = 10
			
			#NOTE: Need to modify the triangles slightly to compensate for the thicker front edge
				#Also, coordinates are messed up.  Remember, up is neg-y
			
			#Front side, left edge
			@window.draw_triangle(@shape.x, @shape.y, color, 
									@shape.x, @shape.y - @shape.height, color,
									@shape.x - side_thickness, @shape.y - @shape.height, color, z)
			#Front side, right edge
			@window.draw_triangle(@shape.x + @shape.width, @shape.y, color, 
							@shape.x + @shape.width, @shape.y - @shape.height, color,
							@shape.x + @shape.width + side_thickness, @shape.y - @shape.height, color, z)
			#Top side, left edge
			@window.draw_triangle(@shape.x, @shape.y - @shape.height, color,
									@shape.x, @shape.y - @shape.height - @shape.depth, color,
									@shape.x - side_thickness, @shape.y - @shape.height, color, z)
			#Top side, right edge
			@window.draw_triangle(@shape.x + @shape.width, @shape.y - @shape.height, color,
							@shape.x + @shape.width, @shape.y - @shape.height - @shape.depth, color,
							@shape.x + @shape.width + side_thickness, @shape.y - @shape.height, color)
			
			#Top side, back edge
			@window.draw_line(@shape.x, @shape.y - @shape.height - @shape.depth, color,
								@shape.x + @shape.width, @shape.y - @shape.height - @shape.depth, color)
			#Top side, front edge, AKA front side, top edge
			@window.draw_line(@shape.x, @shape.y - @shape.height, color,
								@shape.x + @shape.width, @shape.y - @shape.height, color)
			#Front side, bottom edge
			@window.draw_line(@shape.x, @shape.y, color,
								@shape.x + @shape.width, @shape.y, color)
			#Back side, bottom edge
			@window.draw_line(@shape.x, @shape.y - @shape.depth, color,
								@shape.x + @shape.width, @shape.y - @shape.depth, color)
		end
	end
end
