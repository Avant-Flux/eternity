require 'rubygems'

require 'gosu'
require 'texplay'
require 'chipmunk'

require 'set'

class AnimationEditor < Gosu::Window
	def initialize
		fps = 60
		# Window should have a 16:9 aspect ratio
		super(1100, 619, false, (1.0/fps)*1000)
		self.caption = "Animation Editor"
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		
		@mode = :rotate
		
		@sidebar_width = 300
		@modes =	{:vertex => {:sidebar => VertexSidebar.new(self, @font, @sidebar_width), 
								:view => VertexView.new()},
					:rotate => {:sidebar => RotateSidebar.new(self, @font, @sidebar_width), 
								:view => RotateView.new()}}
	end
	
	def update
		#~ puts @mode
		@modes[@mode].each_value do |zone|
			zone.update
		end
	end
	
	def draw
		@modes[@mode].each_value do |zone|
			zone.draw
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbTab
				if @mode == :vertex
					@mode = :rotate
				else # :rotate
					@mode = :vertex
				end
		end
	end
	
	def button_up(id)
		
	end
	
	private
	
	def update_vertex_mode
		# Current vert properties
		@vert = Pivot.new 1, 1
		@part = Part.new "Test Part", [@vert]
	end
end

class Sidebar
	def initialize(window, font, title, width, padding, color=Gosu::Color::BLUE)
		@window = window
		@font = font
		
		@title = title
		@width = width
		@padding = padding
		@color = color
		
		@top_margin = @padding + @font.height + 10
		
		puts @width
		
		@top = 0
		@bottom = @window.height
		@left = @window.width-@width
		@right = @window.width
	end
	
	def update
		
	end
	
	def draw
		draw_bg
		draw_title
	end
	
	def draw_bg
		@window.draw_quad	@left, @top, @color,
							@right, @top, @color,
							@left, @bottom, @color,
							@right, @bottom, @color
	end
	
	def draw_title
		@font.draw @title, @left+@padding, @top+@padding, 0
	end
end

class VertexSidebar < Sidebar
	def initialize(window, font, width, color=Gosu::Color::BLUE)
		super window, font, "Vertex", width, 20, color
	end
	
	def update
		super
	end
	
	def draw
		super
		@font.draw	"Testing", @left+@padding, @top_margin, 0
	end
end

class VertexView
	def initialize
		
	end
	
	def update
		
	end
	
	def draw
		
	end
end

class RotateSidebar < Sidebar
	def initialize(window, font, width, color=Gosu::Color::BLUE)
		super window, font, "Rotate", width, 20, color
	end
	
	def update
		super
	end
	
	def draw
		super
		label = "Angle:"
		@font.draw	label, @left+@padding, @top_margin, 0
		
		offset = @font.width*label.length
		
		@window.draw_quad	
	end
end

class RotateView
	def initialize
		
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
