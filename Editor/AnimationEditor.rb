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
		
		@mode = :texture
		@modes = {}
		[:vertex, :rotate, :texture].each do |mode|
			sidebar = (eval "#{mode.to_s.capitalize}Sidebar.new(self, @space, @font, 300)")
			view  = (eval "#{mode.to_s.capitalize}View.new(self)")
			
			@modes[mode] = {:sidebar => sidebar, :view => view}
		end
		
		@states = []
		switch_mode @mode
		
		# Allow UI objects to overlap
		@space.set_default_collision_handler do
			false
		end
		
		@mouse = MouseHandler.new @space, CP::ALL_LAYERS
	end

	def update
		@space.step
		
		@states.each do |zone|
			zone.update
		end
	end

	def draw
		@font.draw "Modes: (T)exture, (V)ertex, (R)otate", 10, 10, 0
		@font.draw "Press corresponding letter to switch to that mode", 10, 10+@font.height, 0
		@states.each do |zone|
			zone.draw
		end
		#~ @font.draw "mouse: #{@mouse_shape.body.p.x}, #{@mouse_shape.body.p.y}", 0,0,0
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
	end
	
	def button_up(id)
		
	end
	
	def needs_cursor?
		true
	end
	
	def switch_mode(mode)
		@mode = mode
		
		# Remove old states from CP::Space
		@states.each do |state|
			state.remove_from @space if state.respond_to? :remove_from
		end
		
		@states.clear
		
		# Add new states to render stack
		@states << @modes[@mode][:view]
		@states << @modes[@mode][:sidebar]
		
		# Add new states to space
		@states.each do |state|
			state.add_to @space if state.respond_to? :add_to
		end
	end
end

class Sidebar < Widget::Div
	def initialize(window, space, font, title, width, options={})
		options =	{
						:background_color => Gosu::Color::BLUE,
						
						:width => width,
						:height => 100,
						:height_units => :percent,
						
						:padding_top => 50,
						:padding_bottom => 30,
						:padding_left => 30,
						:padding_right => 30
					}.merge! options
		
		super window, window.width-width, 0, options
		
		@font = font
		@title = Widget::Label.new window, -20,-40,
				:relative => self, :width => 100, :height => 30,
				:background_color => Gosu::Color::NONE,
				:text => title, :font => font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom
				
	end
	
	def update
		
	end
	
	def draw
		super
		@title.draw
	end
	
	def click_event
		puts "been clicked: #{self.class}"
	end
	
	def add_to(space)
		super space
		@title.add_to space
	end
	
	def remove_from(space)
		super space
		@title.remove_from space
	end
end

class VertexSidebar < Sidebar
	def initialize(window, space, font, width, options={})
		super window, space, font, "Vertex", width, options
		
		@label = Widget::Label.new window, 0, 0, 
				:relative => self, :width => 120, :height => 30,
				:text => "Current Part", :font => font,
				 :background_color => Gosu::Color::GREEN
		
		@button = Widget::Button.new window, 130, 0, 
				:relative => self, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE do
			puts "testing button"
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
		super
		@label.draw
		@button.draw
	end
	
	def add_to(space)
		super space
		@label.add_to space
		@button.add_to space
	end
	
	def remove_from(space)
		super space
		@label.remove_from space
		@button.remove_from space
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
	def initialize(window, space, font, width, options={})
		options[:background_color] = Gosu::Color.argb(255, 50, 135, 0)
		
		super window, space, font, "Rotate", width, options
	end
	
	def update
		super
	end
	
	def draw
		super
		# Current vert properties
		@vert = Pivot.new 1, 1
		@part = Part.new "Test Part", [@vert]
		
		#~ label = "Angle:"
		#~ @font.draw	label, 0, 0, 0, :color => Gosu::Color::BLACK
		
		#~ offset = @font.text_width label
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
	def initialize(window, space, font, width, options={})
		options[:background_color] = Gosu::Color::YELLOW
		
		super window, space, font, "Texture", width, options
		
		@add_layer = Widget::Button.new window, 0,0,
				:relative => self, :width => 130, :height => 30,
				:background_color => Gosu::Color::RED,
				:text => "Add New Layer", :font => font, :color => Gosu::Color::WHITE do
			puts "new layer"
		end
		
		@div = Container.new window, self
		@layer = LayerIndicator.new window, @div
	end
	
	def update
		super
		@add_layer.update
		@div.update
		@layer.update
	end
	
	def draw
		super
		@add_layer.draw
		@div.draw
		@layer.draw
	end
	
	class Container < Widget::Div
		def initialize(window, parent)
			super window, 0,50,
				:relative => parent, :background_color => Gosu::Color::RED,
				:width => 100, :width_units => :percent, 
				:height => (parent.height(:meters)-parent.padding[:bottom]-parent.padding[:bottom]-50),
				:padding_top => 5, :padding_bottom => 5, :padding_left => 3, :padding_right => 3
		end
	end
	
	class LayerIndicator < Widget::Div
		def initialize(window, parent)
			super window, 0,0, 
				:relative => parent, 
				:background_color => Gosu::Color::WHITE,
				:width => 100, :width_units => :percent, :height => 50
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
