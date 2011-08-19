#!/usr/bin/ruby

Dir.chdir File.dirname(__FILE__)

#~ BASE_DIRECTORY = File.dirname(__FILE__)[0..(File.dirname(__FILE__).rindex File::SEPARATOR)]

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
require_all './Utilities'
require_all './Physics'
require_all './GameObjects'
require_all './Equipment'
require_all './GameStates'
require_all './Drawing'
require_all './UI'

class Game_Window < Gosu::Window
	def initialize
		fps = 60
		# Window should have a 16:9 aspect ratio
		super(1100, 619, false, (1.0/fps)*1000)
		self.caption = "Project ETERNITY"
		
		Cacheable.sprite_directory = "./Sprites"
		
		#~ $console = GosuConsole.new(self, 50)
		# Create a camera object which can be passed to all contained LevelState objects
		@camera = Camera.new self
		
		#~ Need to reverse the order of traversal for :above using #reverse_each
		#~ if the states need to updated it the proper order.
		
		# Display splash while the game loads up
		#~ @states.new_gamestate SplashState, "Startup"
		
		# Initialize input handler
		@inpman = InputHandler.new
		init_input
		
		
		# Load player character data
		@player = Player.new self, "Bob"
		@player.equipment[:right_hand] = Weapons::Swords::Scimitar.new
		@player.equipment[:left_hand] = Weapons::Guns::Handgun.new
		
		@states = GameStateManager.new self, @camera, @player
		
		# Init starting level of the game
		@states.new_gamestate LevelState, "Scrapyard"
		
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
		
		#~ if $console.visible?
			#~ $console.draw
			#~ flush()
		#~ end
		
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10, 10, 10
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
		@inpman.bind_action :up, Gosu::KbUp
		@inpman.bind_action :down, Gosu::KbDown
		@inpman.bind_action :left, Gosu::KbLeft
		@inpman.bind_action :right, Gosu::KbRight
		
		@inpman.new_action :toggle_menu, :rising_edge do
			@states.toggle_menu
			#~ puts "switch to menu mode"
			@inpman.mode = :menu
		end
		@inpman.bind_action :toggle_menu, Gosu::KbTab
		
		@inpman.new_action :jump, :rising_edge do
			if @player.intense
				puts "intense jump"
			end
			@player.jump
		end
		@inpman.bind_action :jump, self.char_to_button_id(".")
		
		@inpman.new_action :intense, :rising_edge do
			@player.intense = true
		end
		@inpman.new_action :intense, :falling_edge do
			@player.intense = false
		end
		@inpman.bind_action :intense, Gosu::KbLeftShift
		
		
		#~ [:magic, :left_hand, :right_hand].each do |attack_type|
			#~ @inpman.new_action attack_type, :falling_edge do
				#~ attack = attack_type.to_s
				#~ 
				#~ charge =	if attack_type == :magic
								#~ @player.magic_charge
							#~ else
								#~ @player.equipment[attack_type].charge
							#~ end
				#~ 
				#~ if charge
					#~ attack = "charge_" + attack
				#~ end
				#~ 
				#~ if @player.intense
					#~ attack = "intense_" + attack
				#~ end
				#~ 
				#~ @player.send attack.to_sym
			#~ end
			
			#~ @inpman.new_sequence "intense_#{attack_type}".to_sym, :falling_edge do
				#~ @player.send "intense_#{attack_type}".to_sym
				#~ puts "hey"
			#~ end
			
			#~ eval %Q{
				#~ @inpman.new_hold "prep_charge_#{attack_type}".to_sym, 2000 do
					#~ 
				#~ end
			#~ }
		#~ end
		
		["magic", "left_hand", "right_hand"].each do |attack_type|
		
			code = %Q{
				@inpman.new_action :#{attack_type}, :falling_edge do
					attack = "#{attack_type}"
				}
				
			code << if attack_type == "magic"
					%Q{
					if @player.magic_charge
					}
				else
					%Q{
					if @player.equipment[:#{attack_type}].charge
					}
				end
			code << %Q{			
						attack = "charge_" + attack
					end
					
					#~ if @player.intense
						#~ attack = "intense_" + attack
					#~ end
					
					@player.send attack.to_sym
				end
			}
			
			#~ puts code
			
			
			@inpman.new_sequence "intense_#{attack_type}".to_sym, :rising_edge do
				@player.send "intense_#{attack_type}".to_sym
				#~ puts "hey"
				#~ self.close
			end
			
			eval code
			
			charge_time = 
			eval %Q{
				#~ @inpman.new_hold "prep_charge_#{attack_type}".to_sym, 2000 do
					
				#~ end
			}
		end
		
		@inpman.bind_sequence :intense_magic, [:intense, :magic]
		@inpman.bind_sequence :intense_left_hand, [:intense, :left_hand]
		@inpman.bind_sequence :intense_right_hand, [:intense, :right_hand]
		
		@inpman.bind_action :magic, Gosu::KbO
		@inpman.bind_action :left_hand, Gosu::KbE
		@inpman.bind_action :right_hand, Gosu::KbU
		
		
		@inpman.new_chord :magic_jump, :rising_edge do
			puts "magic jump"
		end
		@inpman.bind_chord :magic_jump, [:magic, :jump]
		
		
		#~ @inpman.bind_chord :intense_magic, [:intense, :magic]
		#~ @inpman.bind_chord :intense_left_hand, [:intense, :left_hand]
		#~ @inpman.bind_chord :intense_right_hand, [:intense, :right_hand]
		
		
		
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
		@inpman.bind_action :zoom_in, Gosu::KbJ
				
		@inpman.new_action :zoom_out, :active do
			@camera.zoom_out
		end
		@inpman.bind_action :zoom_out, Gosu::KbK
		
		@inpman.new_action :zoom_reset, :rising_edge do
			@camera.zoom_reset
		end
		@inpman.bind_action :zoom_reset, Gosu::Kb0
		
		
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
	end
	
	def save_keybindings
		
	end
	
	def load_keybindings
		
	end
end

class Numeric
	def to_seconds
		self / 1000
	end
end

Game_Window.new.show
