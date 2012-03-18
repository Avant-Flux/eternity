#!/usr/bin/ruby
path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR)-1)]
Dir.chdir path

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'require_all'
#~ require 'profile'

require_all './Physics'

require_all './Combat'
require_all './Drawing'
require_all './Equipment'
require_all './Stats'
require_all './Titles'

require_all './Utilities'

require_all './GameObjects'
require_all './GameStates'

require_all './UI'

class WidgetTestInterface < InterfaceState
	def initialize(window, space, layers, name, open, close)
		super(window, space, layers, name, open, close)
		
		container = Widget::Div.new window, 0,0, 
						:background_color => Gosu::Color::WHITE,
						:top => 10, :bottom => 10, :left => 10, :right => 10
		add_gameobject container
		
		add_gameobject Widget::Div.new window, 0,0, 
						:relative => container,
						:background_color => Gosu::Color::RED,
						:top => 10, :bottom => :auto, :left => 10, :right => :auto,
						:width => 50, 
		#~ add_gameobject Widget::Div.new window, 0,0, 
						#~ :relative => container,
						#~ :background_color => Gosu::Color::GREEN,
						#~ :top => 10, :bottom => 10, :left => 10, :right => 10
		#~ add_gameobject Widget::Div.new window, 0,0, 
						#~ :relative => container,
						#~ :background_color => Gosu::Color::BLUE,
						#~ :top => 10, :bottom => 10, :left => 10, :right => 10
	end
	
	def update
		super
	end
	
	def draw
		super
	end
end

class WidgetTest < Gosu::Window
	def initialize
		fps = 30
		# Window should have a 16:9 aspect ratio
		super(1100, 619, false, (1.0/fps)*1000)
		
		Cacheable.sprite_directory = "./Sprites"
		
		@player = Player.new self, "Bob"
		
		@camera = Camera.new self, 0.01
		@camera.px = 0
		@camera.py = 0
		
		@camera.transparency_mode = :always_on
		
		@states = GameStateManager.new self, @camera, @player
		
		#~ @grid = @states.new_gamestate Grid, "Grid" # Create the grid state
		
		@interface = @states.new_interface(WidgetTestInterface, "Interface")
		#~ @mouse = @interface.mouse
		
		@font = Gosu::Font.new(self, "Trebuchet MS", 25)
		# Hide fps by default
		@show_fps = false
	end
	
	def update
		if @pan
			center_x = self.width/2.0
			center_y = self.height/2.0
			
			x = mouse_x - center_x
			y = mouse_y - center_y
			
			@camera.px += x.to_meters
			@camera.py += y.to_meters
		end
		
		@states.update
		
		@camera.update
	end
	
	def draw
		@states.draw
		
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10, 10, 10
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
	end
	
	def button_up(id)
		#~ if id == Gosu::MsRight
			#~ @pan = false
		#~ elsif id == Gosu::KbLeftControl || id == Gosu::KbRightControl
			#~ @mouse.mode = :default
		#~ end
	end
	
	def needs_cursor?
		true
	end
end

WidgetTest.new.show
