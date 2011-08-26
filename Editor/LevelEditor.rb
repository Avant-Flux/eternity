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
		
		@mouse = @states.new_interface(LevelEditorInterface, "Interface").mouse
		
		#~ @states.new_level LevelState, "Scrapyard"
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
	
	def initialize(window, space, layers, name, open, close)
		super(window, space, layers, name, open, close)
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		space.set_default_collision_func do
			false
		end
		
		@mouse = MouseHandler.new space, layers
		
		sidebar_width = 250
		@sidebar = Widget::Div.new window, window.width-sidebar_width,0,
				:width => sidebar_width, :height => 100, :height_units => :percent,
				:background_color => Gosu::Color::BLUE,
				:padding_top => 10, :padding_bottom => 10, :padding_left => 10, :padding_right => 10
		
		@name_box = Widget::TextField.new window, 0,0,
				:relative => @sidebar,
				:background_color => Gosu::Color::WHITE,
				:width => 100, :width_units => :percent, :height => @font.height,
				:text => "", :font => @font, :color => Gosu::Color::BLUE
		
		@load = Widget::Button.new window, 0,30,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Load", :font => @font, :color => Gosu::Color::BLUE do
			puts "load"
			
			begin
				@state = open.call LevelState, @name_box.text
				@name_box.editable = false
			rescue
				@name_box.reset
				@name_box.text = "File not found"
			end
			
			
			#~ @open.call 
			#~ @gc = true
		end
		
		@save = Widget::Button.new window, 120,30,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Save", :font => @font, :color => Gosu::Color::BLUE do
			puts "Save"
			
			begin
				close.call @name_box.text
			rescue
				puts "save error"
			end
			
			#~ @gc = true
		end
		
		@export_uvs = Widget::Button.new window, 120,70,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Export", :font => @font, :color => Gosu::Color::BLUE do
			puts "Export"
			
			if @state
				path = File.join LevelState::LEVEL_DIRECTORY, "#{@state.name}Texures"
				@state.export path
			else
				puts "No level to export"
			end
		end
		
		
		add_gameobject @sidebar
		add_gameobject @name_box
		add_gameobject @load
		add_gameobject @save
		add_gameobject @export_uvs
		#~ @sidebar.add_to space
		#~ @load.add_to space
		#~ @save.add_to space
	end
	
	def update
		super
	end
	
	def draw
		@gameobjects.each do |obj|
			obj.draw
		end
	end
end

LevelEditor.new.show
