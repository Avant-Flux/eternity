#!/usr/bin/ruby

require 'rubygems'

require 'gosu'
require 'texplay'
require 'chipmunk'

require 'require_all'

require 'set'

path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR))]
Dir.chdir path

require_all './Utilities'
require_all './Physics'
require_all './Equipment'
require_all './GameObjects'
require_all './GameStates'
require_all './Drawing'
require_all './UI'

class LevelEditor < Gosu::Window
	def initialize
		fps = 60
		# Window should have a 16:9 aspect ratio
		super(1100, 619, false, (1.0/fps)*1000)
		self.caption = "Level Editor"
		
		Cacheable.sprite_directory = "./Sprites"
		
		@player = Player.new self, "Bob"
		
		@camera = Camera.new self, 0.01
		@camera.px = 0
		@camera.py = 0
		
		@states = GameStateManager.new self, @camera, @player
		@states.delete "HUD"
		
		@mouse = @states.new_gamestate(LevelEditorInterface, "Interface").mouse
		
		@states.new_gamestate LevelState, "Scrapyard"
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
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbT
				switch_mode :texture
			when Gosu::KbV
				switch_mode :vertex
			when Gosu::KbR
				switch_mode :rotate
			when Gosu::MsLeft
				@mouse.click CP::Vec2.new(mouse_x, mouse_y)
		end
		
		if id == Gosu::MsWheelUp
			@camera.zoom_in
		elsif id == Gosu::MsWheelDown
			@camera.zoom_out
		end
		
		if id == Gosu::MsMiddle
			@pan = true
		end
	end
	
	def button_up(id)
		if id == Gosu::MsMiddle
			@pan = false
		end
	end
	
	def needs_cursor?
		true
	end
end

class LevelEditorInterface < InterfaceState
	attr_reader :mouse
	
	def initialize(window, space, layers, name, player)
		super(window, space, layers, name, player)
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		space.set_default_collision_func do
			false
		end
		
		@mouse = MouseHandler.new space, CP::ALL_LAYERS
		
		sidebar_width = 250
		@sidebar = Widget::Div.new window, window.width-sidebar_width,0,
				:width => sidebar_width, :height => 100, :height_units => :percent,
				:background_color => Gosu::Color::BLUE,
				:padding_top => 10, :padding_bottom => 10, :padding_left => 10, :padding_right => 10
		
		@load = Widget::Button.new window, 0,0,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Load", :font => @font, :color => Gosu::Color::BLUE do
			puts "load"
			#~ @states.new_gamestate Prompt, "Loading Prompt"
		end
				
		@save = Widget::Button.new window, 120,0,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Save", :font => @font, :color => Gosu::Color::BLUE do
			puts "Save"
		end
		
		
		@sidebar.add_to space
		@load.add_to space
		@save.add_to space
	end
	
	def update
		@sidebar.update
		@load.update
		@save.update
	end
	
	def draw
		@sidebar.draw
		@load.draw
		@save.draw
	end
end

class Prompt < InterfaceState
	def initialize(window, space, layers, name, player)
		super(window, space, layers, name, player)
		
		@visible = false
		@space = space
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		@div = Widget::Div.new window, 0,0,
				:width => 500, :height => 300,
				:padding_top => 40, :padding_bottom => 40, 
				:padding_left => 30, :padding_right => 30
		
		@filefield = Widget::TextField.new window, 0,0,
				:relative => @div,
				:background_color => Gosu::Color::WHITE,
				:width => 100, :width_units => :percent, :height => @font.height,
				:text => "", :font => @font, :color => Gosu::Color::BLUE
		
		@accept = Widget::Button.new window, 0,50,
				:relative => @div, 
				:background_color => Gosu::Color::WHITE,
				:width => 200, :height => 100,
				:text => "Accept", :font => @font, :color => Gosu::Color::BLUE do
			puts "accept"
			self.visible = false
			@gc = true
		end
		
		@cancel = Widget::Button.new window, 220,50,
				:relative => @div, 
				:background_color => Gosu::Color::WHITE,
				:width => 200, :height => 100,
				:text => "Cancel", :font => @font, :color => Gosu::Color::BLUE do
			puts "cancel"
			self.visible = false
			@gc = true
		end
		
		@children = [@div, @accept, @cancel, @filefield]
	end
	
	def update
		@children.each do |child|
			child.update
		end
	end
	
	def draw
		@children.each do |child|
			child.draw
		end
	end
	
	def visible=(bool)
		@visible = bool
		method =	if bool
						:add_to
					else
						:remove_from
					end
		
		@children.each do |child|
			child.send method, @space
		end
	end
end

LevelEditor.new.show
