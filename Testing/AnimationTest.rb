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
		@i = 1
		spritesheet_filename =  "./Sprites/gearblade.dds"
		#~ @frames = Gosu::Image::load_tiles(self, "./Sprites/Creatures/Golem_Walk_S.png", -8, -6, false)
		#~ @frames2 = Gosu::Image::load_tiles(self, "./Sprites/Creatures/Golem_Walk_N.png", -8, -6, false)
		
		#~ @frames = []
		#~ directions = ["South"].each do |direction|
			#~ (1..48).each do |i|
				#~ 
				#~ 
				#~ @frames << load_sprite("Golem", "Walk", direction, i)
			#~ end
		#~ end
		
		#~ @sprite = @frames[@i]
		#~ @sprite = Gosu::Image.new self, "./Sprites/gearblade.dds", false
		
		@sprite = Gosu::Image.new self, "/home/ravenskrag/Code/GameDev/Eternity/Renders/Golem/Walk/South/Render1_0031.png", false
		#~ @sprite = load_sprite("Golem", "Walk", "South", @i)
	end
	
	def update
		@tick += 1
		if @tick == 2
			@i += 1
			#~ @i = 0 if @i == @frames.length
			@i = 1 if @i == 49
			
			@tick = 0
		end
		
		#~ @sprite = @frames[@i]
		@sprite = load_sprite("Golem", "Walk", "North", @i)
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
	
	private
	
	def load_sprite(entity, action, direction, frame)
		filename = "/home/ravenskrag/Code/GameDev/Eternity/Renders/#{entity}/#{action}/#{direction}/Render1_"
		filename << "%04i" % frame
		filename << ".png"
		
		puts filename
		
		return Gosu::Image.new(self, filename, false)
	end
end

Window.new.show
