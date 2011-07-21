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
require 'require_all'
#~ require 'profile'
require_all './Physics'
require_all './GameObjects'
require_all './Equipment'
require_all './GameStates'
require_all './Utilities'
require_all './Drawing'
require_all './UI'

class Game_Window < Gosu::Window
	def initialize
		fps = 60
		# Window should have a 16:9 aspect ratio
		super(1100, 619, false, (1.0/fps)*1000)
		self.caption = "Project ETERNITY"
		
		Cacheable.sprite_directory = "./Sprites"
		
		$console = GosuConsole.new(self, 50)
		# Create a camera object which can be passed to all contained LevelState objects
		@camera = Camera.new self
		
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
			
			new_action :jump, [Gosu::KbU]
	
			new_action :intense, [Gosu::KbLeftShift]
			
			new_action :magic, [Gosu::KbA]
			new_action :left_hand, [Gosu::KbO]
			new_action :right_hand, [Gosu::KbE]
			
			
			new_chord :super, [Gosu::KbLeftShift, Gosu::KbU]
			new_sequence :super2, [Gosu::KbLeftShift, Gosu::KbP]
			new_combo :super3, [Gosu::KbQ, Gosu::KbJ, Gosu::KbK], [1000, 500, 200]
			
			
			# Also defined in Gosu#button_down
				# zoom in bound to scroll up
				# zoom out bound to scroll down
			new_action :zoom_in, [Gosu::KbJ]
			new_action :zoom_out, [Gosu::KbK]
			new_action :zoom_reset, [Gosu::Kb0]
			
			new_action :toggle_menu, [Gosu::KbTab]
		end
		
		# Load player character data
		@player = Player.new self, "Bob"
		@player.equipment[:right_hand] = Weapons::Swords::Scimitar.new
		@player.equipment[:left_hand] = Weapons::Guns::Handgun.new
		
		@states = GameStateManager.new self, @camera, @player
		
		# Init starting level of the game
		@states.new_gamestate LevelState, "Test Level"
		
		# Place player into game world
		@states.add_player @player
		
		# Remove splash and display level
		#~ @states.pop
		#~ @states.restore
		
		@camera.follow @player
		
		@font = Gosu::Font.new(self, "Trebuchet MS", 25)
		
		# Hide fps by default
		@show_fps = false
	end
	
	def update
		process_input
		@inpman.update
		
		$console.update
		@states.update
		
		@camera.update
	end
	
	def draw
		@states.draw
		
		if $console.visible?
			$console.draw
			flush()
		end
		
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10, 10, 10
		end
		
		color =	if @inpman.active?(:super) 
					Gosu::Color::CYAN
				elsif @inpman.active?(:super2)
					Gosu::Color::RED
				elsif @inpman.active?(:super3)
					Gosu::Color::FUCHSIA
				else
					Gosu::Color::NONE
				end
		draw_quad	800, 30, color,
						1000, 30, color,
						800, 50, color,
						1000, 50, color
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
		if id == Gosu::MsWheelUp
			@camera.zoom_in
		elsif id == Gosu::MsWheelDown
			@camera.zoom_out
		end
	end
	
	def button_up(id)
		@inpman.button_up(id)
		
		if id == Gosu::KbA
			@steppable = false
		end
	end
	
	def needs_cursor?()
		true
	end
	
	private
	
	def process_input
		dir = @inpman.direction
		#~ puts dir
		
		if dir != nil
			if @inpman.active? :intense
				@player.run
			else
				@player.walk
			end
			
			@player.move dir
		end
		
		if @inpman.active?(:jump)
			@player.jump
		end
		
		[:magic, :left_hand, :right_hand].each do |attack_type|
			if @inpman.hold_duration(attack_type) > @player.charge_time(attack_type)
				if :magic
					@player.magic_charge = true
				else
					@player.equipment[attack_type].charge = true
				end
			end
			
			if @inpman.finish? attack_type
				charged =	if :magic
								@player.magic_charge
							else
								@player.equipment[attack_type].charge
							end
				
				if @inpman.active? :intense
					if charged
						@player.send "intense_charge_#{attack_type}".to_sym
					else
						@player.send "intense_#{attack_type}".to_sym
					end
				elsif charged
					@player.send "charge_#{attack_type}".to_sym
				else
					@player.send attack_type
				end
			end
		end
		
		if @inpman.active?(:zoom_in)
			@camera.zoom_in
		elsif @inpman.active?(:zoom_out)
			@camera.zoom_out
		elsif @inpman.active?(:zoom_reset)
			@camera.zoom_reset
		end
		
		if @inpman.begin?(:toggle_menu)
			@states.toggle_menu
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
