#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 06.11.2010

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
require 'chingu'

require 'chipmunk'
require 'Chipmunk/ChipmunkInterfaceMod'

require 'Entity'
require "Creature"
require 'Character'
require 'Player'

require 'Utilities/FPSCounter'
require 'Utilities/InputHandler'
require 'Animations'
require 'Background'

class Game_Window < Gosu::Window
	# The number of steps to process every Gosu update
	SUBSTEPS = 6
	
	attr_reader :screen_x, :screen_y
	
	def initialize
		super(1100, 688, false)
		self.caption = "Project ETERNITY"
		@fpscounter = FPSCounter.new(self)
		
		@inpman = InputHandler.new
		
		@space = CP::Space_3D.new
		
		@player = Player.new(self, @space, "Bob", [300, 400, 0])
		#~ characters = Array.new
		#~ 19.times do |i|
			#~ x = (i * 30) % 800 + 100
			#~ y = (i * 100) % 600 + 100
			#~ 
			#~ characters << Character.new(self, @space, "NPC", [x, y, 0])
		#~ end
		#~ @player.track(characters[0])
		#~ @player.track(characters[9])
		#~ @player.track(characters[12])
		#~ @player.track(characters[3])
		#~ @player.track(characters[18])
		
		@effect = Animations::Effect.new(self, "Fireball")
		
		@background = Background.new(self,"Sprites/Textures/grass_texture2.png")
	end
	
	def update
		@fpscounter.update
		
		SUBSTEPS.times do
			@effect.update

			Entity.transfer_x_for_all
			Entity.reset_all
			
			@inpman.update
			process_input
			
			Entity.apply_gravity_to_all
			Entity.update_all
			
			#~ puts "Player: #{@player.body.x}, #{@player.body.y}, #{@player.body.z}"
			
						
			@space.step
		end
	end
	
	def draw
		@background.draw
		@fpscounter.draw
		@effect.draw(60,60,3)
		
		Entity.draw_all
	end
	
	def button_down(id)
		@inpman.button_down(id)
		
		if id == Gosu::Button::KbEscape
			close
		end
		if id == Gosu::Button::KbF
			@fpscounter.toggle
		end
	end
	
	def button_up(id)
		@inpman.button_up(id)
	end
	
	private 
	
	def process_input
		dir = @inpman.direction
		if dir != nil
			if @inpman.active? :run
				@player.run dir
			else
				@player.move dir
			end
		end
		
		if @inpman.active?(:jump)
			@player.jump
		end
	end
end

class InputHandler
	def direction
		up =	active? :up
		down =	active? :down
		left =	active? :left
		right =	active? :right
		
		result =	if up && left
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
		bindAction(:up, Gosu::KbUp)
		bindAction(:up, Gosu::KbA)
		createAction(:down)
		bindAction(:down, Gosu::KbDown)
		createAction(:left)
		bindAction(:left, Gosu::KbLeft)
		createAction(:right)
		bindAction(:right, Gosu::KbRight)
		
		createAction(:jump)
		bindAction(:jump, Gosu::KbLeftShift)
		
		createAction(:run)
		bindAction(:run, Gosu::KbLeftControl)
	end
end

Game_Window.new.show
