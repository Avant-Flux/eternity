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

require_all './Physics'
require_all './GameObjects'
require_all './Drawing'
require_all './UI'

class AnimationEditor < Gosu::Window
		def initialize
		fps = 60
		# Window should have a 16:9 aspect ratio
		super(1100, 619, false, (1.0/fps)*1000)
		self.caption = "Animation Editor"
		
		@space = Physics::Space.new self.update_interval/1000, -9.8, 0.05
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		
		@mode = :rotate
		
		@modes = {}
		[:vertex, :rotate, :texture].each do |mode|
			@modes[mode] = {
							:sidebar => (eval "#{mode.to_s.capitalize}Sidebar.new(self, @font, 300)"),
							:view => (eval "#{mode.to_s.capitalize}View.new(self)")
							}
		end
		
		@space.add_collision_handler :pointer, :button, Widgets::Button::CollisionHandler.new
	end

	def update
		#~ puts @mode
		@modes[@mode].each_value do |zone|
			zone.update
		end
	end

	def draw
		@font.draw "Press <TAB> to switch modes", 10, 10, 0
		@modes[@mode].each_value do |zone|
			zone.draw
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbT
				@mode = :texture
			when Gosu::KbV
				@mode = :vertex
			when Gosu::KbR
				@mode = :rotate
		end
	end
	
	def button_up(id)
		
	end
end

class Sidebar
	def initialize(window, font, title, width, options={})
		options =	{
						:background_color => Gosu::Color::BLUE,
						
						:padding_top => 30,
						:padding_bottom => 10,
						:padding_left => 10,
						:padding_right => 10
					}.merge! options
		
		@window = window
		@font = font
		
		@div = Widgets::Div.new window, [window.width-width, 0], width, window.height, options
		
		@title = title
	end
	
	def update
	
	end
	
	def draw(&block)
		@div.draw do
			@font.draw @title, 0, -@font.height, 0, :color => Gosu::Color::BLACK
			
			block.call
		end
	end
end

class VertexSidebar < Sidebar
	def initialize(window, font, width, options={})
		super window, font, "Vertex", width, options
		
		@button = Widgets::Button.new window, Gosu::Color::WHITE, [20,20], 100, 20 do
			
		end
	end
	
	def update
		super
		# Current vert properties
		@vert = Pivot.new 1, 1
		@part = Part.new "Test Part", [@vert]
		
		@button.update
	end
	
	def draw
		super do
			@font.draw "Testing", 0, 0, 0, :color => Gosu::Color::BLACK
				@button.draw
		end
	end
end

class VertexView
	def initialize(window)
	
	end
	
	def update
	
	end
	
	def draw
	
	end
end

class RotateSidebar < Sidebar
	def initialize(window, font, width, options={})
		options[:background_color] = Gosu::Color.argb(255, 50, 135, 0)
		
		super window, font, "Rotate", width, options
	end
	
	def update
		super
	end
	
	def draw
		super do
			# Current vert properties
			@vert = Pivot.new 1, 1
			@part = Part.new "Test Part", [@vert]
			
			label = "Angle:"
			@font.draw	label, 0, 0, 0, :color => Gosu::Color::BLACK
			
			#~ offset = @font.text_width label
		end
	end
end

class RotateView
	def initialize(window)
	
	end
	
	def update
	
	end
	
	def draw
	
	end
end

class TextureSidebar < Sidebar
	def initialize(window, font, width, options={})
		options[:background_color] = Gosu::Color::YELLOW
		
		super window, font, "Texture", width, options
	end
	
	def update
		super
	end
	
	def draw
		super do
			
		end
	end
end

class TextureView
	def initialize(window)
	
	end
	
	def update
	
	end
	
	def draw
	
	end
end

# Defines the pivot for a body part
class Pivot
	attr_accessor :vert, :rotation
	
	def initialize(vert, rotation)
		@vert = vert
		@rotation = rotation
	end
end

# Defines the body part to be modified
class Part
	attr_accessor :name, :verts
	
	def initialize(name, verts)
		@name = name
		@verts = verts
	end
end

AnimationEditor.new.show
