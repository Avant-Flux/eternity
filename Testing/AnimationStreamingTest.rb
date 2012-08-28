Dir.chdir File.dirname(__FILE__)
Dir.chdir ".." # Move into parent folder, IE project root

require 'rubygems'
require 'gosu'

class ImageBuffer
	attr_reader :columns, :rows
	
	def initialize(gosu_image)
		@value = gosu_image.to_blob
		@columns = gosu_image.width
		@rows = gosu_image.height
	end
	
	def to_blob
		return @value
	end
end

class AnimationStreamingTest < Gosu::Window
	def initialize()
		@target_fps = 60
		# Window should have a 16:9 aspect ratio
		super(1280, 720, false, (1.0/@target_fps)*1000)
		self.caption = "Animation Test"
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		
		
		filename = "/home/ravenskrag/Code/GameDev/Eternity/Renders/Golem/Walk/South/Render1_0031.png"
		#~ filename = "/home/ravenskrag/Code/GameDev/Eternity/Renders/Spritesheets/Golem_Walk_S.png"
		spritesheet = Gosu::Image.new(self, filename, false)
		@buffer = ImageBuffer.new spritesheet
		puts "buffer size: #{@buffer.columns} x #{@buffer.rows}"
		
		@i = 0
		@sprite_width = 900
		@sprite_height = 900
		#~ @sprite = Gosu::Image.new(self, @buffer, false, 0,0, @sprite_width,@sprite_height)
		@sprite = Gosu::Image.new(self, @buffer, false)
	end
	
	def update
		#~ x = 0
		#~ y = 0
		#~ puts "sprite coordinates on texture: #{x}, #{y}"
		puts "tick: #{@i}"
		@i += 1
		#~ @sprite = Gosu::Image.new(self, @buffer, false, x,y, @sprite_width,@sprite_height)
		@sprite = Gosu::Image.new(self, @buffer, false)
	end
	
	def draw
		@sprite.draw 0,0,0
		
		@font.draw "fps: #{Gosu::fps}", 200,0,0, 1,1, Gosu::Color::FUCHSIA
	end
	
	def button_down(id)
		# Part of the update loop, not event-driven
		close if id == Gosu::KbEscape
	end
	
	def button_up(id)
		# Part of the update loop, not event-driven
	end
	
	def needs_cursor?
		true
	end
end

AnimationStreamingTest.new.show
