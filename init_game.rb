#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 12.09.2009

begin
  # In case you use Gosu via rubygems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
begin
require 'lib/gosu'
rescue LoadError
require 'gosu'
end

require "FPSCounter"

class Game_Window < Gosu::Window
	attr_reader :screen_x
	attr_reader :screen_y
	def initialize
		super(800, 600, false)
		self.caption = "Project ETERNITY"
		@fpscounter = FPSCounter.new(self)
	end
	
	def update
	end
	
	def draw
	end
	
	def button_down(id)
		if id == Gosu::Button::KbEscape then
			close
		end
		if id == Gosu::Button::KbF
			@fpscounter.show_fps = !@fpscounter.show_fps
		end
	end
end

window = Game_Window.new
window.show