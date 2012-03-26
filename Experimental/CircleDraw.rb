#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'chingu'
require 'texplay'

require 'opengl'
#~ require 'gl'
#~ require 'glu'

include Gl
include Glu
include Glut
 
class Window < Gosu::Window
	def initialize
		super(1100, 688, false)
		self.caption = "Draw Circles"
		@img = TexPlay.create_blank_image(self, 500,500)
		
		#~ @angle = 1 * Math::PI / 180
		@angle = 1.0/128 * 2*Math::PI
		
		# Give angle as a slope, aka, a fraction of a circle
		@slope = Math.tan @angle
		
		#~ draw_ring(300,300, 100, 360, Gosu::Color.new(0xFFFFFFFF))
		draw_ring_bresenham 300,300, 100, @angle, Gosu::Color.new(0xFFFFFFFF)
		draw_ring_bresenham 300,300, 100-20, @angle, Gosu::Color.new(0xFFFFFFFF)
		
		@font = Gosu::Font.new(self, "Trebuchet MS", 25)
		
		@quadric = gluNewQuadric()

	end
	
	def update
		#~ draw_ring(300,300, 100, 360, Gosu::Color.new(0xFFFFFFFF))
	end
	
	def draw
		@font.draw "FPS: #{Gosu::fps}", 10, 10, 10
		
		
		draw_ring_partialdisk(300,300, 100, @angle, Gosu::Color.new(0xFFFFFFFF))
		#~ @img.draw(0,0,10)
		#~ draw_ring2(300,300, 100, @angle, Gosu::Color.new(0xFFFFFFFF))
	end
	
	def button_down(id)
		if id == Gosu::Button::KbEscape
			close
		end
		
		if id == Gosu::Button::KbUp
			#~ @angle += 1.0/128 * 2*Math::PI
			@angle += 10
			#~ @slope = Math.tan @angle
			#~ draw_ring_bresenham 300,300, 100, @angle, Gosu::Color.new(0xFFFFFFFF)
			#~ draw_ring_bresenham 300,300, 100-20, @angle, Gosu::Color.new(0xFFFFFFFF)
		end
		if id == Gosu::Button::KbDown
			@angle -= 10
		end
		
		if @angle < 0
			@angle = 0
		elsif @angle > 360
			@angle = 360
		end
	end
	
	def button_up(id)
		
	end
	
	def draw_ring_partialdisk(cx,cy, r, angle, color, options={})
		options = {
			:stroke_width => 3,	# Width of the line
			:slices => 30, # Number of subdivisions around the z axis.
			:loops => 1, # Number of concentric rings about the origin.
			
			:start_angle => 0
		}.merge! options
		
		self.gl do
			#~ glPolygonMode(GL_FRONT, GL_FILL) # Probably doesn't affect quadrics
			
			glPushMatrix()
				#~ glLoadIdentity()
				
				glColor3f(color.red, color.green, color.blue)
				glTranslatef(cx, cy, 0)
				# Given Gosu's coordinate system, 0deg is down, pos rotation is CCW
				gluPartialDisk(@quadric, r-options[:stroke_width], r, 
								10, options[:loops],
								options[:start_angle], angle)
			glPopMatrix()
		end
	end
	
	def draw_ring(cx, cy, r, angle, colors)
		#~ Basic algorithm for drawing circle by kyonides
		
		#~ 0.step(angle, 0.1) do |a1|
			#~ a2 = a1 + 1
			#~ @img.line(cx + Gosu.offset_x(a1, r+40), cy + Gosu.offset_y(a1, r+40),
					#~ cx + Gosu.offset_x(a2, r-28), cy + Gosu.offset_y(a2, r-28))
		#~ end
		
		
		#Assume that the ring starts to fill in from the 0 deg dir in the Gosu plane
		# Draw circle outline
		inner_r = r - 30
		@img.circle cx,cy,r
		@img.circle cx,cy,inner_r
		
		# Draw Starting axis
		draw_ring_line cx,cy, r, 0
		
		# Draw displacement line
		draw_ring_line cx,cy, r, @angle
		
		# Fill the region in the middle
		dx = r * Math.cos(angle*Math::PI/180)
		dy = r * Math.sin(angle*Math::PI/180)
		@img.fill cx+dx-1,cy+dy+1
	end
	
	def draw_ring_line(cx,cy, r, angle)
		# Draw a line at the specified angle.  Should be drawn relative to given circle center.
		dx = r * Math.cos(angle*Math::PI/180)
		dy = r * Math.sin(angle*Math::PI/180)
		@img.line cx,cy, cx+dx,cy+dy
	end
	
	def draw_ring2(cx, cy, r, angle, colors)
		@ring2_cache = Hash.new
		
		0.step(angle, 0.1) do |i|
			dx = dy = nil
			if @ring2_cache[i]
				dx = @ring2_cache[i][0]
				dy = @ring2_cache[i][1]
			else
				dx = r * Math.cos(i*Math::PI/180)
				dy = r * Math.sin(i*Math::PI/180)
				
				@ring2_cache[i] = [dx, dy]
			end
			
			self.draw_line	cx,cy, colors,
							cx+dx,cy+dy, colors, 100
		end
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
			
			#~ if @angle > 0
				#~ if (x)/(y).to_f < @slope
					#~ @img.pixel cx+y, cy+x # Oct 1
				#~ end
			#~ end
			#~ if @angle > 2*Math::PI*1/8
				#~ if (y)/(x).to_f < @slope
					#~ @img.pixel cx+x, cy+y # Oct 2
				#~ end
			#~ end
			#~ if @angle > 2*Math::PI*2/8
				#~ if (y)/(-x).to_f < @slope
					#~ @img.pixel cx-x, cy+y # Oct 3
				#~ end
			#~ end
			#~ if @angle > 2*Math::PI*3/8
				#~ if (x)/(-y).to_f < @slope
					#~ @img.pixel cx-y, cy+x # Oct 4
				#~ end
			#~ end
			#~ if @angle > 2*Math::PI*4/8
				#~ if (-x)/(-y).to_f < @slope
					#~ @img.pixel cx-y, cy-x # Oct 5
				#~ end
			#~ end
			#~ if @angle > 2*Math::PI*5/8
				#~ if (-y)/(-x).to_f < @slope
					#~ @img.pixel cx-x, cy-y # Oct 6
				#~ end
			#~ end
			#~ if @angle > 2*Math::PI*6/8
				#~ if (-y)/(x).to_f < @slope
					#~ @img.pixel cx+x, cy-y # Oct 7
				#~ end
			#~ end
			#~ if @angle > 2*Math::PI*7/8
				#~ if (-x)/(y).to_f < @slope
					#~ @img.pixel cx+y, cy-x # Oct 8
				#~ end
			#~ end
		end
	end
end

Window.new.show
