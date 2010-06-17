#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.17.2010
 
#!/usr/bin/ruby
#~ Written by: kyonides
#~ Edited by: Jason
#~ Date last edited: 06.15.2010
require 'rubygems'
require 'gosu'
require 'chingu' 
 
class Window < Gosu::Window
	def initialize
		super(1100, 688, false)
		self.caption = "Draw Circles"
	end
	
	def update
		
	end
	
	def draw
		draw_ring(300,300, 100, 360, Gosu::Color.new(0xFFFFFFFF))
	end
	
	def button_down(id)
		if id == Gosu::Button::KbEscape
			close
		end
	end
	
	def button_up(id)
		
	end
	
	def draw_ring(cx, cy, r, angle, colors, z=150)
		if !colors.is_a? Array or colors.size == 1
			draw_monocolor_ring(cx, cy, r, angle, colors, z)
		elsif colors.size == 2
			draw_bicolor_ring(cx, cy, r, angle, colors, z)
		elsif colors.size == 4
			draw_multicolor_ring(cx, cy, r, angle, colors, z)
		end
	end
	
	def draw_monocolor_ring(cx, cy, r, angle, color, z)
		0.step(angle, 0.1) do |a1|
			if a1 > 270
				a2 = a1 + 1
			draw_line(cx + Gosu.offset_x(a1, r+40),
				cy + Gosu.offset_y(a1, r+40), color,
				cx + Gosu.offset_x(a2, r-28),
				cy + Gosu.offset_y(a2, r-28), color, z)
			elsif a1 > 180
				a2 = a1 + 1
			draw_line(cx + Gosu.offset_x(a1, r+30),
				cy + Gosu.offset_y(a1, r+30), color,
				cx + Gosu.offset_x(a2, r-28),
				cy + Gosu.offset_y(a2, r-28), color, z)
			elsif a1 > 90
				a2 = a1 + 1
			draw_line(cx + Gosu.offset_x(a1, r+20),
				cy + Gosu.offset_y(a1, r+20), color,
				cx + Gosu.offset_x(a2, r-28),
				cy + Gosu.offset_y(a2, r-28), color, z)
			elsif a1 > 0
				a2 = a1 + 1
			draw_line(cx + Gosu.offset_x(a1, r),
				cy + Gosu.offset_y(a1, r), color,
				cx + Gosu.offset_x(a2, r-28),
				cy + Gosu.offset_y(a2, r-28), color, z)
			end
			#~ a2 = a1 + 1
			#~ draw_line(cx + Gosu.offset_x(a1, r),
				#~ cy + Gosu.offset_y(a1, r), color,
				#~ cx + Gosu.offset_x(a2, r-28),
				#~ cy + Gosu.offset_y(a2, r-28), color, z)
		end
	end
	
	def draw_bicolor_ring(cx, cy, r, angle, colors=[], z=150)
		0.step(angle, 1) do |a1|
		a2 = a1 + 1
		self.draw_line(cx + Gosu.offset_x(a1, r),
			cy + Gosu.offset_y(a1, r), colors[1],
			cx + Gosu.offset_x(a2, r-28),
			cy + Gosu.offset_y(a2, r-28), colors[0], z)
		end
	end
	
	def draw_multicolor_ring(cx, cy, r, angle, colors=[], z=150)
	color = colors[0] if angle > 270 && angle <= 360
	color = colors[1] if angle > 180 && angle <= 270
	color = colors[2] if angle > 90 && angle <= 180
	color = colors[3] if angle > 0 && angle <= 90
	0.step(angle, 1) do |a1|
	a2 = a1 + 1
	self.draw_line(cx + Gosu.offset_x(a1, r),
		cy + Gosu.offset_y(a1, r), color,
		cx + Gosu.offset_x(a2, r-28),
		cy + Gosu.offset_y(a2, r-28), 0xFF000000, z)
	end
	end
end

Window.new.show
