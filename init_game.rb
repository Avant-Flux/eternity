#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.10.2010

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

require 'chipmunk'
require 'ChipmunkInterfaceMod'

#~ require 'ManageAssets'
require 'Entity'
require "Creature"
require 'Character'
require 'Player'

require 'FPSCounter'
require 'InputHandler'
require 'Animations'

class Game_Window < Gosu::Window
	# The number of steps to process every Gosu update
	SUBSTEPS = 6
	
	attr_reader :screen_x, :screen_y
	
	def initialize
		super(800, 600, false)
		self.caption = "Project ETERNITY"
		@fpscounter = FPSCounter.new(self)
		
		@inpman = InputHandler.new
		@inpman.def_kb_bindings
		
		@player = Player.new("Bob", Animations.player(self), [30,50,00])
		#~ @anim = Gosu::Image::load_tiles(self, "Sprites/Lightning_Ray.png", 192, 192, false)
		#~ @cur = @anim[0]
		
		@space = CP::Space_3D.new
		@space.add(@player)
	end
	
	def update
		if dir = @inpman.direction	#Get the direction to face from input and make sure it is not nil
			@player.direction = dir
		end
		if @inpman.active?(:jump)
			@player.jump
		end
		#~ @cur = @anim[Gosu::milliseconds / 100 % @anim.size]
		
		
		
		@inpman.update()
		
		SUBSTEPS.times do
			@space.step
			puts "#{@player.body.x}, #{@player.body.y}, #{@player.body.z}"
			
			@player.body.apply_gravity
		end
	end
	
	def draw
		@player.draw
		#~ @cur.transparent("#000000").draw(0,0,3)
		#~ @cur.draw(60,60,3)
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
	
	def def_kb_bindings
		createAction(:up)
		bindAction(:up, Gosu::Button::KbUp)
		createAction(:down)
		bindAction(:down, Gosu::Button::KbDown)
		createAction(:left)
		bindAction(:left, Gosu::Button::KbLeft)
		createAction(:right)
		bindAction(:right, Gosu::Button::KbRight)
		createAction(:jump)
		bindAction(:jump, Gosu::Button::KbLeftShift)
	end
	
	def active?(action)
		self.query(action) == :active
	end
end

Game_Window.new.show
