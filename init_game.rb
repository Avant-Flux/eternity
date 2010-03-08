#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 03.07.2010

begin
  # In case you use Gosu via rubygems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
begin
	require 'lib/gosu'
	require 'lib/chingu'
rescue LoadError
	require 'gosu'
	require 'chingu'
end

require "FPSCounter"
require "InputHandler"
require "ManageAssets"

class Game_Window < Gosu::Window
	attr_reader :screen_x, :screen_y
	
	def initialize
		super(800, 600, false)
		self.caption = "Project ETERNITY"
		@fpscounter = FPSCounter.new(self)
		
		
		@animations = Gosu::Image::load_tiles(self, "Sprites/Sprites.png", 40, 80, false)
		p @animations
		#~ @player = Player.new(animations, [0,0,0])
	end
	
	def update
	end
	
	def draw
		#@player.draw
		x = y = 20
		@animations.each do |a|
			a.draw(x, y, 1, 1, 1)
			x += 80 
			#~ y += 85
		end
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

Game_Window.new.show
