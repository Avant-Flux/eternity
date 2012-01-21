module Widget
	class CircularStatusBar < UI_Object
		# Note that arc lengths are always specified from the 0rad position being a completely
		# empty bar.  The direction the bar is drawn on the image is always from 
		# the pos-x direction of the image (default, right), and will increase cw
		# 
		# This behavior can be modified by rotating the image (to change start location)
		# or by inverting the image (change direction in which the bar fills up)
		
		def initialize(window, z)
			super(window, z)
			
			@img = TexPlay.create_blank_image(window, 500,500)
			
			# Essentially any "color" can be used for the eraser, as long as the alpha channel
			# is fully transparent.  Though Gosu may have a pre-defined transparency constantant.
			@eraser = Gosu::Color::NONE
			@color = Gosu::Color.new(0xFFFFFFFF)
			
			#~ @angle = 1 * Math::PI / 180
			@angle = 1.0/128 * 2*Math::PI
			
			# Give angle as a slope, aka, a fraction of a circle
			@slope = Math.tan @angle
			
			draw_ring_bresenham 300,300, 100, @angle, Gosu::Color.new(0xFFFFFFFF)
			draw_ring_bresenham 300,300, 100-20, @angle, Gosu::Color.new(0xFFFFFFFF)
		end
		
		def update(percent)
			# Update the displayed angle to match the given percent
		end
		
		def draw(x,y,z)
			# Draw the ring centered on the position specified by the central coord
			# Coordinates are given in window coordinates, in units of px
			@img.draw(0,0,10)
			# can use #draw_rot to turn the image
			# use negative x drawing factor to mirror image
		end
		
		private
		
		# #increase_to and #decrease_to should use different colors in order to
		# draw or erase the bar respectively
		
		def increase_to(angle)
			# Increase the angle of the status bar and update the image accordingly
			@angle = angle
			@slope = Math.tan @angle
			draw_ring_bresenham 300,300, 100, @angle, Gosu::Color.new(0xFFFFFFFF)
			draw_ring_bresenham 300,300, 100-20, @angle, Gosu::Color.new(0xFFFFFFFF)
		end
		
		def decrease_to(angle)
			# Decrease the angle of the status bar and update the image accordingly
			@angle = angle
			@slope = Math.tan @angle
			draw_ring_bresenham 300,300, 100, @angle, @eraser
			draw_ring_bresenham 300,300, 100-20, @angle, @eraser
		end
		
		def draw_ring_bresenham(cx, cy, r, angle, colors)
			f = 1 - r
			ddF_x = 1
			ddF_y = -2*r
			x = 0
			y = r
			
			@img.pixel cx, cy + r if @angle >= 2*Math::PI * 1/4	# TAU/4
			@img.pixel cx, cy - r if @angle >= 2*Math::PI * 3/4	# 3 TAU/4
			@img.pixel cx + r, cy if @angle >= 2*Math::PI		# TAU or 0
			@img.pixel cx - r, cy if @angle >= 2*Math::PI * 1/2	# TAU / 2
			
			while x < y
				#~ puts f
				#~ puts "#{x} #{y}"
				# ddF_x == 2 * x + 1
			    # ddF_y == -2 * y
			    # f == x*x + y*y - radius*radius + 2*x - y + 1
				
				if f >= 0
					y -= 1;
					ddF_y += 2
					f += ddF_y
				end
				
				x += 1
				ddF_x += 2
				f += ddF_x
				
				# Outer is radian measure
				# Inner is side ratio (tangent)
				
				if @angle < 2*Math::PI*1/8
					# Within first octant
					if (x.to_f)/(y) < @slope
						@img.pixel cx+y, cy+x # Oct 1
					end
				else
					# Expands past first octant
					@img.pixel cx+y, cy+x # Oct 1
					
					if @angle <= 2*Math::PI*2/8
						# Within octant 2
						if (y.to_f)/(x) < @slope
							@img.pixel cx+x, cy+y # Oct 2
						end
					else
						# Expands past octant 2
						@img.pixel cx+x, cy+y # Oct 2
						
						if @angle <= 2*Math::PI*3/8
							# Within octant 3
							if (y.to_f)/(-x) < @slope
								@img.pixel cx-x, cy+y # Oct 3
							end
						else
							# Expands past octant 3
							@img.pixel cx-x, cy+y # Oct 3
							
							if @angle <= 2*Math::PI*4/8
								# Within octant 4
								if (x.to_f)/(-y) < @slope
									@img.pixel cx-y, cy+x # Oct 4
								end
							else
								# Expands past octant 4
								@img.pixel cx-y, cy+x # Oct 4
								
								if @angle <= 2*Math::PI*5/8
									# Within octant 5
									if (-x.to_f)/(-y) < @slope
										@img.pixel cx-y, cy-x # Oct 5
									end
								else
									# Expands past octant 5
									@img.pixel cx-y, cy-x # Oct 5
									
									if @angle <= 2*Math::PI*6/8
										# Within octant 6
										if (-y.to_f)/(-x) < @slope
											@img.pixel cx-x, cy-y # Oct 6
										end
									else
										# Expands past octant 6
										@img.pixel cx-x, cy-y # Oct 6
										
										if @angle <= 2*Math::PI*7/8
											# Within octant 7
											if (-y.to_f)/(x) < @slope
												@img.pixel cx+x, cy-y # Oct 7
											end
										else
											# Expands past octant 7
											@img.pixel cx+x, cy-y # Oct 7
											
											if @angle < 2*Math::PI*8/8
												# Within octant 8
												if (-x.to_f)/(y) < @slope
													@img.pixel cx+y, cy-x # Oct 8
												end
											else
												# Expands past octant 8
												# Expanding past is impossible, thus, full circle
												@img.pixel cx+y, cy-x # Oct 8
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
