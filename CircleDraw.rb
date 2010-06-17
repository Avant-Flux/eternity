#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.17.2010

require 'rubygems'
require 'gosu'
require 'chingu'
require 'texplay'
 
class Window < Gosu::Window
	def initialize
		super(1100, 688, false)
		self.caption = "Draw Circles"
		@img = TexPlay.create_blank_image(self, 500,500)
		draw_ring(300,300, 100, 360, Gosu::Color.new(0xFFFFFFFF))
	end
	
	def update
		
	end
	
	def draw
		@img.draw(0,0,10)
	end
	
	def button_down(id)
		if id == Gosu::Button::KbEscape
			close
		end
	end
	
	def button_up(id)
		
	end
	
	def draw_ring(cx, cy, r, angle, colors)
		0.step(angle, 0.1) do |a1|
			a2 = a1 + 1
			@img.line(cx + Gosu.offset_x(a1, r+40), cy + Gosu.offset_y(a1, r+40),
					cx + Gosu.offset_x(a2, r-28), cy + Gosu.offset_y(a2, r-28))
		end
	end
end

Window.new.show
