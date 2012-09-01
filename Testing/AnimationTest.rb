Dir.chdir File.dirname(__FILE__)
Dir.chdir ".." # Move into parent folder, IE project root

require './GameWindow'
require 'rubygems'
require 'require_all'
#~ require_all './Physics'
#~ require_all './GameObjects/Cameras'


require 'gosu'


class SpriteCache
	# Caching has two levels:
	# Assets not in VRAM will cache-miss and be fetched from RAM
	# Assets not in RAM will cache-miss and be fetched from disk
	# 
	# Due to the speed of disk-fetching, assets should be kept in RAM for as long as possible.
	# However, Gosu::Image.new loads into texture memory, so the caching is more of a recycle bin
	# 
	# LOAD ENTIRE SPRITESHEET INTO MEMORY AT ONCE
	# Then, load frames into VRAM as necessary
	def initialize(cache_size)
		@size = cache_size
		
		# RAM Cache
		# keys are animation identifiers, values are arrays of frames (raw RGBA blob data)
		@cache = Hash.new
		
		# Frames currently in VRAM
		# keys are full animation identifiers, values are arrays of Gosu::Image objects
		@frames = Hash.new #
	end
	
	# Returns one sprite for the specified frame of animation
	def [](entity, action, direction, frame)
		key = "#{entity}_#{action}_#{direction}"
		
		if @frames[key]
			if @frames[key][frame]
				return @frames[key][frame]
			else
				# Frame does not exist in VRAM.
				# CACHE MISS
				# Go to cache in RAM
				
			end
		else
			# Not a single frame from the animation requested is currently loaded into VRAM
			
		end
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
		
		# Raven:	Based on experimental data on my machine, the buffer should be about 60 sprites, 
		# 			given the current size of the golem sprite.  However, the golem is the largest
		# 			animated sprite thus far.  Ideally, the buffer size would be in bytes, not
		# 			simply the number of frames.
		# The buffer must load frames which have not yet been called, so that the game does not lag
		# while trying to load new frames.  This may not actually be possible if the engine
		# blocks on the IO operation of loading sprites from the disk.
		
		#~ @spritesheet = Gosu::Image.new(self, "/home/ravenskrag/Code/GameDev/Eternity/Renders/Golem/Walk/South/Render1_0031.png", false).to_blob
		@spritesheet = ("\0"*4 * 900 * 900) # Uncompressed image data in RAM
		
		@sprite = Gosu::Image.new(self, @spritesheet, false) # Load ONE sprite into VRAM
	end
	
	def update
		#~ @tick += 1
		#~ if @tick == 2
			#~ @i += 1
			#~ @i = 0 if @i == @frames.length
			#~ @i = 1 if @i == 49
			#~ 
			#~ @tick = 0
		#~ end
		
		#~ @sprite = @frames[@i]
		#~ @sprite = load_sprite("Golem", "Walk", "North", @i)
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
		#~ @sprite.draw_rot x, y, 0, 0,0.5,1, @zoom, @zoom
		
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
