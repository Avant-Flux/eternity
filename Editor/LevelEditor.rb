#!/usr/bin/ruby
path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR)-1)]

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

# Require specific files for the editor
require_all './Editor/LevelEditor_lib/'

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
		
		@camera.transparency_mode = :always_on
		
		@states = GameStateManager.new self, @camera, @player
		
		@mouse = @states.new_interface(LevelEditorInterface, "Interface").mouse
		
		#~ @states.new_level LevelState, "Scrapyard"
		
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
			when Gosu::MsLeft
				@mouse.click CP::Vec2.new(mouse_x, mouse_y)
		end
		
		if id == Gosu::KbF
			@show_fps = !@show_fps
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

LevelEditor.new.show
