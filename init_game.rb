#!/usr/bin/ruby

Dir.chdir File.dirname(__FILE__)

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
require 'require_all'
#~ require 'profile'
require_all './Physics'
require_all './GameObjects'
require_all './GameStates'
require_all './Utilities'
require_all './Drawing'
require_all './UI'

class Game_Window < Gosu::Window
	def initialize
		fps = 60
		super(1100, 688, false, (1.0/fps)*1000)
		self.caption = "Project ETERNITY"
		
		Cacheable.sprite_directory = "./Sprites"
		
		$console = GosuConsole.new(self, 50)
		# Create a camera object which can be passed to all contained LevelState objects
		@camera = Camera.new self
		@states = GameStateManager.new self, @camera
		
		#~ Need to reverse the order of traversal for :above using #reverse_each
		#~ if the states need to updated it the proper order.
		
		# Display splash while the game loads up
		#~ @states.new_gamestate SplashState, "Startup"
		
		# Initialize input handler
		@inpman = InputHandler.new do
			new_action :up, [Gosu::KbUp]
			new_action :down, [Gosu::KbDown]
			new_action :left, [Gosu::KbLeft]
			new_action :right, [Gosu::KbRight]
			
			new_action :jump, [Gosu::KbE]
	
			new_action :run, [Gosu::KbLeftShift]
			
			new_chord :super, [Gosu::KbLeftShift, Gosu::KbU]
			new_sequence :super2, [Gosu::KbLeftShift, Gosu::KbP]
			new_combo :super3, [Gosu::KbQ, Gosu::KbJ, Gosu::KbK], [1000, 500, 200]
		end
		
		# Load player character data
		@player = Player.new self, "Bob"
		#~ 
		# Init starting level of the game
		@states.new_gamestate LevelState, "Test Level"
		
		# Place player into game world
		@states.add_player @player
		
		# Remove splash and display level
		#~ @states.pop
		#~ @states.restore
		
		@font = Gosu::Font.new(self, "Trebuchet MS", 25)
		
		# Hide fps by default
		@show_fps = false
	end
	
	def update
		$console.update
		@states.update
	end
	
	def draw
		if $console.visible?
			$console.draw
			flush()
		end
		@states.draw
		
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10, 10, 10
		end
	end
	
	def button_down(id)
		@inpman.button_down(id)
		
		if id == Gosu::KbEscape
			close
		end
		if id == Gosu::KbF
			@show_fps = !@show_fps
		end
		if id == Gosu::KbA
			@steppable = true
		end
		#~ puts button_id_to_char id
		#~ puts id
	end
	
	def button_up(id)
		@inpman.button_up(id)
		
		if id == Gosu::KbA
			@steppable = false
		end
	end
	
	private
	
	def init_space
		#~ space = Physics::Space.new self.update_interval/1000, -9.8, 0.12
		#~ 
		#~ entity_handler = CollisionHandler::Entity.new
		#~ entity_env_handler = CollisionHandler::Entity_Env.new
		#~ camera_collision = CollisionHandler::Camera.new
#~ 
		#~ space.add_collision_handler :entity, :environment, entity_env_handler
		#~ space.add_collision_handler :entity, :building, entity_env_handler
		#~ space.add_collision_handler :entity, :entity, entity_handler
		#~ 
		#~ space.add_collision_handler :camera, :render_object, camera_collision
		#~ 
		#~ space.add_collision_func :render_object, :render_object, :begin do |arbiter|
			#~ false
		#~ end
		#~ 
		#~ return space
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
		end
		
		if @inpman.active?(:jump)
			@player.jump
		end
		
		if @inpman.active?(:super) || @inpman.active?(:super2) || @inpman.active?(:super3)
			puts "BAM!#{@i += 1}"
		end
	end
	
	def save_keybindings
		
	end
	
	def load_keybindings
		
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
end

class Numeric
	def to_seconds
		self / 1000
	end
end

Game_Window.new.show
