Dir.chdir File.dirname(__FILE__)
Dir.chdir ".." # Move into parent folder, IE project root

#~ require './GameWindow'
require 'rubygems'
require 'gosu'

#~ class Window < GameWindow
class Window < Gosu::Window
	def initialize
		@target_fps = 60
		# Window should have a 16:9 aspect ratio
		super(1280, 720, false, (1.0/@target_fps)*1000)
		self.caption = "Animation Test"
		@show_fps = false
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		@zoom = 1
		
		
		@i = 0
		spritesheet_filename = "./Development/Models/golem/walk.png"
		@frames = Gosu::Image::load_tiles(self, spritesheet_filename, -8, -6, false)
		@sprite = @frames[@i]
		#~ @sprite = Gosu::Image.new self, "./Development/Models/golem/0001.png", false
	end
	
	def update
		@i = 0
	end
	
	def draw
		@sprite.draw 0,0,0, @zoom, @zoom
		
		format = "%0.3f"
		@font.draw "zoom: #{format % @zoom}", 0,0,0
	end
	
	def button_down(id)
		# Part of the update loop, not event-driven
		close if id == Gosu::KbEscape
		
		if id == Gosu::MsWheelDown
			@zoom -= 0.01
		elsif id == Gosu::MsWheelUp
			@zoom += 0.01
		end
		
		if @zoom < 0
			@zoom = 0
		end
	end
	
	def button_up(id)
		# Part of the update loop, not event-driven
	end
	
	def needs_cursor?
		true
	end
end

Window.new.show
