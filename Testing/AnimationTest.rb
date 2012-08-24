Dir.chdir File.dirname(__FILE__)
Dir.chdir ".." # Move into parent folder, IE project root

require './GameWindow'
require 'rubygems'
require 'require_all'
#~ require_all './Physics'
#~ require_all './GameObjects/Cameras'


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
		
		@camera = Camera::TrimetricCamera.new self, nil
		@camera.followed_entity = Entity.new self
		
		
		@terrain_color = Gosu::Color::WHITE
		@terrain_width = 20
		@terrain_depth = 20
		@camera.followed_entity.body.p.x = @terrain_width / 2
		@camera.followed_entity.body.p.y = @terrain_depth / 2
		
		
		@tick = 0
		@i = 0
		spritesheet_filename = "./Sprites/Creatures/golem_walk.png"
		@frames = Gosu::Image::load_tiles(self, spritesheet_filename, -8, -6, false)
		@sprite = @frames[@i]
		#~ @sprite = Gosu::Image.new self, "./Development/Models/golem/0001.png", false
	end
	
	def update
		@tick += 1
		if @tick == 2
			@i += 1
			@i = 0 if @i == @frames.length
			
			@tick = 0
		end
		
		@sprite = @frames[@i]
	end
	
	def draw
		@camera.draw_trimetric_now do
			draw_quad	0,0,							@terrain_color,
						@terrain_width, 0,				@terrain_color,
						@terrain_width, @terrain_depth,	@terrain_color,
						0, @terrain_depth,				@terrain_color
		end
		
		#~ position = @camera.followed_entity.body.p.to_screen
		#~ puts position
		x = self.width/2
		y = self.height/4*3
		@sprite.draw_rot x, y, 0, 0,0.5,1, @zoom, @zoom
		
		format = "%0.3f"
		@font.draw "zoom: #{format % @zoom}", 0,0,0
		
		# Game engine framerate display
		@font.draw "fps: #{Gosu::fps}", 200,0,0, 1,1, Gosu::Color::FUCHSIA
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
