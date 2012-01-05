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
		fps = 30
		# Window should have a 16:9 aspect ratio
		super(1100, 619, false, (1.0/fps)*1000)
		self.caption = "Level Editor v0.1"
		
		Cacheable.sprite_directory = "./Sprites"
		
		@player = Player.new self, "Bob"
		
		@camera = Camera.new self, 0.01
		@camera.px = 0
		@camera.py = 0
		
		@camera.transparency_mode = :always_on
		
		@states = GameStateManager.new self, @camera, @player
		
		@grid = @states.new_gamestate Grid, "Grid" # Create the grid state
		
		@interface = @states.new_interface(LevelEditorInterface, "Interface", @grid)
		@mouse = @interface.mouse
		
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
		
		#~ x = @camera.p.x.to_px(@camera.zoom)
		#~ y = @camera.p.y.to_px(@camera.zoom)
		#~ x = @camera.vertex_absolute(0).x.to_px(@camera.zoom)
		#~ y = @camera.vertex_absolute(0).y.to_px(@camera.zoom)
		x = self.width / 2
		y = self.height / 2
		self.draw_quad	x-10, y-10, Gosu::Color::RED,
						x+10, y-10, Gosu::Color::RED,
						x-10, y+10, Gosu::Color::RED,
						x+10, y+10, Gosu::Color::RED, 50000
		
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10, 10, 10
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::MsLeft
				# Separate actions for when clicking in the UI versus in the scene
				if mouse_x > self.width - @interface.width
					# Clicking on UI
					#~ puts "UI"
					click_UI
				else
					# Clicking in scene
					#~ puts "Scene"
					click_scene
				end
			when Gosu::MsRight
				@pan = true
			when Gosu::MsWheelUp
				@camera.zoom_in
			when Gosu::MsWheelDown
				@camera.zoom_out
			when Gosu::KbF
				@show_fps = !@show_fps
		end
		
		if id == Gosu::KbLeftControl || id == Gosu::KbRightControl
			@mouse.mode = :multiple_select
		end
	end
	
	def button_up(id)
		if id == Gosu::MsRight
			@pan = false
		elsif id == Gosu::KbLeftControl || id == Gosu::KbRightControl
			@mouse.mode = :default
		end
	end
	
	def needs_cursor?
		true
	end
	
	private
	
	def click_UI
		@mouse.click_UI CP::Vec2.new(mouse_x, mouse_y)
	end
	
	def click_scene
		#~ puts ""
		# Calculate displacement from center of screen in px
		dx_px = mouse_x - self.width/2.0
		dy_px = mouse_y - self.height/2.0
		
		#~ puts "#{dx_px} #{dy_px}"				
		# Use that to calculate displacement from center point of camera tracking
		dx_meters = dx_px / Physics.scale / @camera.zoom
		dy_meters = dy_px / Physics.scale / @camera.zoom
		#~ puts "#{dx_meters} #{dy_meters}"
		
		# Calculate absolute position of click within game world
		v = CP::Vec2.new dx_meters, dy_meters
		v.x += @camera.p.x
		v.y += @camera.p.y
		
		# Initiate click event
		@mouse.click_scene v
	end
end

LevelEditor.new.show
