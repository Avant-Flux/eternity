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
require 'RMagick'

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
		def_kb_bindings
		
		@player = Player.new(Animations.player(self), [30,50,0])
		@anim = Gosu::Image::load_tiles(self, "Sprites/Lightning_Ray.png", 192, 192, false)
		@cur = @anim[0]
	end
	
	def update
		if dir = @inpman.direction	#Get the direction to face from input and make sure it is not nil
			@player.direction = dir
		end
		@cur = @anim[Gosu::milliseconds / 100 % @anim.size]
		
		@inpman.update()
	end
	
	def draw
		@player.draw
		#~ @cur.transparent("#000000").draw(0,0,3)
		@cur.draw(60,60,3)
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
	
	private 
	
	def def_kb_bindings
		@inpman.createAction(:up)
		@inpman.bindAction(:up, Gosu::Button::KbUp)
		@inpman.createAction(:down)
		@inpman.bindAction(:down, Gosu::Button::KbDown)
		@inpman.createAction(:left)
		@inpman.bindAction(:left, Gosu::Button::KbLeft)
		@inpman.createAction(:right)
		@inpman.bindAction(:right, Gosu::Button::KbRight)
	end
end

class InputHandler
	def direction
		up =	self.query(:up) == :active
		down =	self.query(:down) == :active
		left =	self.query(:left) == :active
		right =	self.query(:right) == :active
		
		result = if up && left
			:up_left
		elsif up && right
			:up_right
		elsif down && left
			:down_left
		elsif down && right
			:down_right
		elsif up
			:up
		elsif down
			:down
		elsif left
			:left
		elsif right
			:right
		else
			nil #No button for direction pressed
		end

		result
	end
end

Game_Window.new.show
