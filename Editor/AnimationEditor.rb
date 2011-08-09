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
		
		@mode = :rotate
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		
		@sidebar_width = 300
		@sidebar_padding = 10
		@sidebar_color = Gosu::Color::BLUE
	end
	
	def update
		#~ puts @mode
		case @mode
			when :vertex
				update_vertex_mode
			when :rotate
				update_rotate_mode
		end
	end
	
	def draw
		case @mode
			when :vertex
				draw_vertex_mode
			when :rotate
				draw_rotate_mode
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
	
	def draw_sidebar
		draw_quad	self.width-@sidebar_width, 0, @sidebar_color,
					self.width, 0, @sidebar_color,
					self.width-@sidebar_width, self.height, @sidebar_color,
					self.width, self.height, @sidebar_color
	end
	
	def draw_sidebar_title(title, color)
		
		@font.draw title, self.width-@sidebar_width+@sidebar_padding, @sidebar_padding, 0
	end
	
	def update_vertex_mode
		# Current vert properties
		@vert = Vertex.new
	end
	
	def draw_vertex_mode
		draw_sidebar
		draw_sidebar_title "Vertex Mode", Gosu::Color::WHITE
		
		
	end
	
	def update_rotate_mode
		
	end
	
	def draw_rotate_mode
		draw_sidebar
		draw_sidebar_title "Rotate Mode", Gosu::Color::WHITE
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
