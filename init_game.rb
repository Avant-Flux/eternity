#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.15.2010

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
require 'Chipmunk/EternityMod'

require 'GameObjects/Building'
require 'GameObjects/Entity'
require "GameObjects/Creature"
require 'GameObjects/Character'
require 'GameObjects/Player'

require 'Utilities/FPSCounter'
require 'Utilities/InputHandler'
require 'Drawing/Animations'
require 'Drawing/Background'

require 'UI/UserInterface'

class Game_Window < Gosu::Window
	def initialize
		super(1100, 688, false)
		self.caption = "Project ETERNITY"
		@fpscounter = FPSCounter.new(self)
		@inpman = InputHandler.new
		@space = init_CP_Space3D
		
		@building = Building.new(self, @space, :dimensions => [5, 5, 2], :position => [10, 10, 0])
		
		@player = Player.new(self, @space, "Bob", [5, 5, 0])
		characters = Array.new
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
		
		@effect = Animations::Effect.new(self, "Gale")
		
		@background = Background.new(self,"Sprites/Textures/grass_texture2.png")
	end
	
	def update
		@fpscounter.update
		@effect.update
		@building.update
		
		Entity.reset_all
		
		@inpman.update
		process_input
		
		Entity.update_all
		
		#~ puts @player.position
		#~ puts "Building: #{@building.shape.x}, #{@building.shape.y}, #{@building.shape.z}"
		#~ puts "elevation:#{@player.shape.elevation} z:#{@player.shape.z}"
		
		@space.step
	end
	
	def draw
		#~ @background.draw
		@fpscounter.draw
		@building.draw
		@effect.draw(500,60,3)
		
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
	
	def init_CP_Space3D
		space = CP::Space_3D.new
		
		#~ space.add_collision_func :type, :type do |first_shape, second_shape|
			#~ 
		#~ end
		
		space.add_collision_handler :entity, :environment, CollisionHandler::Entity_Env.new
		space.add_collision_handler :entity, :building, CollisionHandler::Entity_Env.new
		
		return space
	end
	
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
