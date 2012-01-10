#!/usr/bin/ruby
#~ Basic algorithm for drawing circle by kyonides

require 'rubygems'
require 'gosu'
require 'chingu'
require 'texplay'
 
class Window < Gosu::Window
	def initialize
		super(1100, 688, false)
		self.caption = "Draw Circles"
		@img = TexPlay.create_blank_image(self, 500,500)
		@angle = 1
		
		#~ draw_ring(300,300, 100, 360, Gosu::Color.new(0xFFFFFFFF))
		
		@font = Gosu::Font.new(self, "Trebuchet MS", 25)
	end
	
	def update
		#~ draw_ring(300,300, 100, 360, Gosu::Color.new(0xFFFFFFFF))
	end
	
	def draw
		@font.draw "FPS: #{Gosu::fps}", 10, 10, 10
		
		#~ @img.draw(0,0,10)
		draw_ring2(300,300, 100, @angle, Gosu::Color.new(0xFFFFFFFF))
	end
	
	def button_down(id)
		if id == Gosu::Button::KbEscape
			close
		end
		
		if id == Gosu::Button::KbUp
			@angle += 10
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
	
	def draw_ring(cx, cy, r, angle, colors)
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
end

Window.new.show
