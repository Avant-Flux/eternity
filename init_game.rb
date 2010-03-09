#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 03.08.2010

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

#~ require 'ManageAssets'
require 'Entity'
require "Creature"
require 'Character'
require 'Player'

require 'FPSCounter'
require 'InputHandler'
require 'Animations'

class Game_Window < Gosu::Window
	attr_reader :screen_x, :screen_y
	
	def initialize
		super(800, 600, false)
		self.caption = "Project ETERNITY"
		@fpscounter = FPSCounter.new(self)
		
		@inpman = InputHandler.new()
		
		@inpman.createAction(:up)
		@inpman.bindAction(:up, Gosu::Button::KbUp)
		@inpman.createAction(:down)
		@inpman.bindAction(:down, Gosu::Button::KbDown)
		@inpman.createAction(:left)
		@inpman.bindAction(:left, Gosu::Button::KbLeft)
		@inpman.createAction(:right)
		@inpman.bindAction(:right, Gosu::Button::KbRight)
		
		@player = Player.new(Animations.player(self), [30,50,0])
	end
	
	def update
		case
			when @inpman.query(:up) == :active
				@player.direction = :up
			when @inpman.query(:down) == :active
				@player.direction = :down
			when @inpman.query(:left) == :active
				@player.direction = :left
			when @inpman.query(:right) == :active
				@player.direction = :right
		end
		
		@inpman.update()
	end
	
	def draw
		@player.draw
		
		#~ x = y = 20
		#~ @animations.each do |a|
			#~ a.draw(x, y, 1, 1, 1)
			#~ x += 80 
			#~ y += 85
		#~ end
	end
	
	
	def button_down(id)
		@inpman.button_down(id)
		
		if id == Gosu::Button::KbEscape
			close
		end
		if id == Gosu::Button::KbF
			@fpscounter.show_fps = !@fpscounter.show_fps
		end
	end
	
	def button_up(id)
		@inpman.button_up(id)
	end
end

class InputHandler
	def direction
		#~ result = 1
		#~ self.query(:up)
		#~ 
		#~ if self.query(:up) == :active		then result *= 2
		#~ if self.query(:down) == :active		then result *= 3
		#~ if self.query(:left) == :active		then result *= 5
		#~ if self.query(:right) == :active	then result *= 7
	end
end

Game_Window.new.show
