#!/usr/bin/ruby

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
require 'Chipmunk/Space_3D'
require 'Chipmunk/EternityMod'

require 'GameObjects/Building'
require 'GameObjects/Entity'
require "GameObjects/Creature"
require 'GameObjects/Character'
require 'GameObjects/Player'
require 'GameObjects/Camera'

require 'Utilities/FPSCounter'
require 'Utilities/InputHandler'
require 'Drawing/Animations'
require 'Drawing/Background'

require 'UI/UserInterface'

class Game_Window < Gosu::Window
	def initialize
		super(1100, 688, false)
		self.caption = "Project ETERNITY"
		$window = self
		
		@fpscounter = FPSCounter.new
		@inpman = InputHandler.new
		@space = init_CP_Space3D
		
		Building.new(@space, :dimensions => [5, 6.5, 2], :position => [6, 11, 0])
		Building.new(@space, :dimensions => [3, 3, 1], :position => [8, 14, 0])
		Building.new(@space, :dimensions => [5, 6.5, 2], :position => [15, 11, 0])
		Building.new(@space, :dimensions => [5, 6.5, 4], :position => [20, 11, 0])
		Building.new(@space, :dimensions => [5, 3, 2], :position => [20, 14, 0])
		Building.new(@space, :dimensions => [5, 6.5, 2], :position => [25, 11, 0])
		Building.new(@space, :dimensions => [5, 6.5, 2], :position => [20, 11-6.5, 0])
		@player = Player.new(@space, "Bob", [5, 5, 0])
		characters = Array.new
		#~ 20.times do |i|
			#~ x = (i * 3) % 8 + 1
			#~ y = (i * 10) % 6 + 1
			#~ 
			#~ characters << Character.new(@space, "NPC", [x, y, 0])
		#~ end
		#~ @player.track(characters[0])
		#~ @player.track(characters[9])
		#~ @player.track(characters[12])
		#~ @player.track(characters[3])
		#~ @player.track(characters[18])
		
		characters << Character.new(@space, "NPC", [5, 8, 0])
		#~ @player.track characters[0]
		
		@UI = UI::Overlay::Status.new(@player)
		$camera = Camera.new(@space, @player)
		
		@effect = Animations::Effect.new($window, "Gale")
		@background = Background.new($window,"Sprites/Textures/grass_texture2.png")
	end
	
	def update
		@fpscounter.update
		@UI.update
		@effect.update
		
		$camera.update
		Entity.reset_all
		
		@inpman.update
		process_input
		
		@space.shapes[:nonstatic].each do |shape|
			shape.entity.update
		end
		@space.shapes[:static].each do |shape|
			shape.entity.update
		end
		
		puts "#{@player.position} + #{@player.elevation}"
		
		@space.step
	end
	
	def draw
		@fpscounter.draw
		@UI.draw
		
		translate(-$camera.x.to_px, -$camera.y.to_px) do
			#~ @background.draw
			@effect.draw(500,60,3)
			
			$camera.queue.each do |i|
				i.draw
			end
		end
	end
	
	def button_down(id)
		@inpman.button_down(id)
		
		if id == Gosu::KbEscape
			close
		end
		if id == Gosu::KbF
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
		entity_env_handler = CollisionHandler::Entity_Env.new
		camera_collision = CollisionHandler::Camera.new

		space.add_collision_handler :entity, :environment, entity_env_handler
		space.add_collision_handler :entity, :building, entity_env_handler
		
		space.add_collision_handler :camera, :entity, camera_collision
		space.add_collision_handler :camera, :building, camera_collision
		
		return space
	end
	
	def process_input
		dir = @inpman.direction
		if dir != nil
			if @inpman.active? :run
				@player.run
			else
				@player.walk
			end
			
			@player.move dir
			$camera.move(@player.movement_force)
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
