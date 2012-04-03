#!/usr/bin/ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'require_all'
#~ require 'profile'
#~ require 'ruby-prof'
#~ RubyProf.start

require_all './Utilities'

require_all './Physics'

require_all './Combat'
require_all './Drawing'
require_all './Equipment'
require_all './Stats'
require_all './Titles'

require_all './GameObjects'
require_all './GameStates'

require_all './UI'


class Game_Window < Gosu::Window
	def initialize
		fps = 60
		# Window should have a 16:9 aspect ratio
		super(1280, 720, false, (1.0/fps)*1000)
		self.caption = "Eternity 0.11.0"
		
		Cacheable.sprite_directory = "./Sprites"
		
		#~ $console = GosuConsole.new(self, 50)
		# Create a camera object which can be passed to all contained LevelState objects
		@camera = Camera.new self
		
		#~ Need to reverse the order of traversal for :above using #reverse_each
		#~ if the states need to updated it the proper order.
		
		@states = GameStateManager.new self, @camera, @player
		
		# Display splash while the game loads up
		#~ @states.new_gamestate SplashState, "Startup"
		
		# Initialize keyboard input handler
		@inpman = InputHandler.new
		init_input
		# Initialize mouse handler
		#~ @mouse = MouseHandler.new space
		
		# Load player character data
		@player = Player.new self, "Bob"
		@player.equipment[:right_hand] = Weapons::Swords::Scimitar.new
		@player.equipment[:left_hand] = Weapons::Guns::Handgun.new
		
		
		@states.new_interface UI_State, "HUD", @player
		
		
		# Init starting level of the game
		@states.new_level LevelState, "Scrapyard"
		
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
		#~ process_input
		@inpman.update
		
		#~ $console.update
		@states.update
		
		@camera.update
	end
	
	def draw
		@states.draw
		
		#~ puts "#{@player.px}, #{@player.py}, #{@player.pz}"
		
		#~ if $console.visible?
			#~ $console.draw
			#~ flush()
		#~ end
		
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10,10,10, :color => Gosu::Color::FUCHSIA
		end
		
		#~ color =	if @inpman.active?(:super) 
					#~ Gosu::Color::CYAN
				#~ elsif @inpman.active?(:super2)
					#~ Gosu::Color::RED
				#~ elsif @inpman.active?(:super3)
					#~ Gosu::Color::FUCHSIA
				#~ else
					#~ Gosu::Color::NONE
				#~ end
		#~ draw_quad	800, 30, color,
						#~ 1000, 30, color,
						#~ 800, 50, color,
						#~ 1000, 50, color
	end
	
	def button_down(id)
		# Part of the update loop, not event-driven
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
		# Part of the update loop, not event-driven
		@inpman.button_up(id)
		
		if id == Gosu::KbA
			@steppable = false
		end
	end
	
	def needs_cursor?()
		true
	end
	
	private
	
	def init_input
		@inpman.mode = :gameplay
		[:up, :down, :left, :right].each do |dir|
			@inpman.new_action dir, :active do 
				if @player.intense
					@player.run
				else
					@player.walk
				end
				
				@player.move dir
			end
			#~ key = eval "Gosu::Kb#{dir.to_s.capitalize}"
			#~ @inpman.bind_action dir, key
		end
		
		@inpman.new_action :toggle_menu, :rising_edge do
			@states.toggle_menu
			#~ puts "switch to menu mode"
			@inpman.mode = :menu
		end
		
		
		@inpman.new_action :jump, :rising_edge do
			if @player.intense
				puts "intense jump"
			end
			@player.jump
		end
		
		
		@inpman.new_action :intense, :rising_edge do
			@player.intense = true
		end
		@inpman.new_action :intense, :falling_edge do
			@player.intense = false
		end
		
		[:magic, :left_hand, :right_hand].each  do |attack_type|
			@inpman.new_action attack_type, :falling_edge do
				attack = attack_type
				
				if attack_type == :magic
					# Short-circuit method and stop casting if MP is too low
					if @player.mp == 0
						return
					end
					
					if @player.magic_charge
						# Current implementation stores one charge, which
						# can be spent on any one ability
						attack = "charge_#{attack}".to_sym
					end
				else
					if @player.equipment[attack_type].charge
						# Current implementation stores one charge, which
						# can be spent on any one ability
						attack = "charge_#{attack}".to_sym
					end
				end
				if @player.intense
					attack = "intense_#{attack}".to_sym
				end
				
				@player.send attack
			end
		
			#~ @inpman.new_sequence "intense_#{attack_type}".to_sym, :falling_edge do
				#~ @player.send "intense_#{attack_type}".to_sym
				#~ puts "hey"
				#~ self.close
			#~ end
			
			#~ @inpman.new_hold "prep_charge_#{attack_type}".to_sym, 2000 do
				#~ 
			#~ end
			#~ charge_time = 
			#~ eval %Q{
				#~ @inpman.new_hold "prep_charge_#{attack_type}".to_sym, 2000 do
					#~ 
				#~ end
			#~ };
		end
		
		@inpman.new_chord :magic_jump, :rising_edge do
			puts "magic jump"
		end
		
		
		
		
		#~ @inpman.bind_hold :charge_left_hand, [:left_hand, 2000]
		
		
		
		
		#~ @inpman.new_action :super
		#~ @inpman.bind_action :super, Gosu::Kb
		#~ 
		#~ @inpman.new_action :super2
		#~ @inpman.bind_action :super2, Gosu::Kb
		#~ 
		#~ @inpman.new_action :super3
		#~ @inpman.bind_action :super3, Gosu::Kb
		
		@inpman.new_action :zoom_in, :active do
			@camera.zoom_in
		end
		
				
		@inpman.new_action :zoom_out, :active do
			@camera.zoom_out
		end
		
		
		@inpman.new_action :zoom_reset, :rising_edge do
			@camera.zoom_reset
		end
		
		
		
			#~ new_chord :super, [Gosu::KbLeftShift, Gosu::KbU]
			#~ new_sequence :super2, [Gosu::KbLeftShift, Gosu::KbP]
			#~ new_combo :super3, [Gosu::KbQ, Gosu::KbJ, Gosu::KbK], [1000, 500, 200]
		
		
		
		@inpman.mode = :menu
		@inpman.new_action :toggle_menu, :rising_edge do
			@states.toggle_menu
			
			#~ puts "switch to gameplay mode"
			#~ puts "closing"
			@inpman.mode = :gameplay
		end	
		@inpman.bind_action :toggle_menu, Gosu::KbTab
		
		
		@inpman.new_action :up, :rising_edge do
			
		end
		@inpman.new_action :down, :rising_edge do
			
		end
		@inpman.new_action :left, :rising_edge do
			
		end
		@inpman.new_action :right, :rising_edge do
			
		end
		
		@inpman.bind_action :up, Gosu::KbUp
		@inpman.bind_action :down, Gosu::KbDown
		@inpman.bind_action :left, Gosu::KbLeft
		@inpman.bind_action :right, Gosu::KbRight
		
		
		@inpman.new_action :back, :rising_edge do
			
		end
		
		@inpman.new_action :confirm, :rising_edge do
			
		end
		
		@inpman.bind_action :back, Gosu::KbEscape
		@inpman.bind_action :confirm, Gosu::KbReturn
		
		
		
		# Must remember to change the mode back to :gameplay before the game starts
		@inpman.mode = :gameplay
		
		@inpman.bind_chord :magic_jump, [:magic, :jump]
		
		
		load_keybindings
	end
	
	def save_keybindings
		# Save bindings in the current format:
		# action_name KeyID
	end
	
	def load_keybindings
		keybindings = Hash.new
		
		user = "Data1"
		path = "./Saves/#{user}/keybindings.txt"
		
		if File.exist? path
			File.open(path).each do |line|
				# Ignore commented lines and whitespace-only lines
				unless line[0] == "#" || line == "" 
					input = line.split
					
					keybindings[input[0].downcase.to_sym] = input[1].to_i
				end
			end
		#~ else
			#~ File.new(path, "w")
			#~ f.puts "# Eternity keybindings for #{user}"
			#~ 
			#~ f.close
		end
		
		keybindings = {
			# Place default keybindings here
			:up => Gosu::KbUp,
			:down => Gosu::KbDown,
			:left => Gosu::KbLeft,
			:right => Gosu::KbRight,
			
			:magic => Gosu::KbO,
			:left_hand => Gosu::KbE,
			:right_hand => Gosu::KbU,
			
			:toggle_menu => Gosu::KbTab,
			:jump => Gosu::KbSpace,
			
			:intense => Gosu::KbLeftShift,
			
			:zoom_in => Gosu::KbJ,
			:zoom_out => Gosu::KbK,
			:zoom_reset => Gosu::Kb0
		}.merge! keybindings
		
		keybindings.each do |action, binding|
			@inpman.bind_action  action, binding
		end
	end
	
	private
	
	def id_to_button(id)
		# Convert the id to the corresponding button, and return a corresponding string
		# This should work for both mouse input, and keyboard input
		char = self.button_id_to_char id
		if char
			return char
		else
			return case id
				when Gosu::MsLeft
					"Left Click"
				when Gosu::MsRight
					"Right Click"
				when Gosu::MsMiddle
					"Middle Click"
				when Gosu::MsWheelUp
					"Wheel Up"
				when Gosu::MsWheelDown
					"Wheel Down"
			end
		end
	end
	
	def path_to_keybindings
		# Return the path to the player's keybinding settings file.
		# If there is no file, make sure to create it first.
		user = "Data1"
		path = "./Saves/#{user}/keybindings.txt"
		
		unless File.exist? path
			File.new(path, "w")
			f.puts "# Eternity keybindings for #{user}"
			
			f.close
		end
		
		
		return path_to_keybindings
	end
end

class Numeric
	def to_seconds
		self / 1000
	end
end

Game_Window.new.show
