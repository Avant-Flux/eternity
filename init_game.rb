#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 05.20.2010

begin
  # In case you use Gosu via rubygems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
begin
	require 'lib/gosu'
	require 'lib/chingu'
rescue LoadError
	require 'gosu'
	require 'chingu'
end
require 'RMagick'

require 'gl'
require 'glu'

include Gl
include Glu

require 'chipmunk'
require 'ChipmunkInterfaceMod'

require 'Entity'
require "Creature"
require 'Character'
require 'Player'

require 'FPSCounter'
require 'InputHandler'
require 'Animations'
require 'Background'

class Game_Window < Gosu::Window
	# The number of steps to process every Gosu update
	SUBSTEPS = 6
	
	attr_reader :screen_x, :screen_y
	
	def initialize
		super(800, 600, false)
		self.caption = "Project ETERNITY"
		@fpscounter = FPSCounter.new(self)
		
		@inpman = InputHandler.new
		@inpman.def_kb_bindings
		
		@space = CP::Space_3D.new
		
		@player = Player.new(@space, "Bob", Animations.player(self), [30, 400, 0])
		@character = Character.new(@space, "NPC", Animations.player(self), [30, 200, 0])
		@c2 = Character.new(@space, "NPC", Animations.player(self), [70, 200, 0])
		@c3 = Character.new(@space, "NPC", Animations.player(self), [120, 200, 0])
		@c4 = Character.new(@space, "NPC", Animations.player(self), [50, 225, 0])
		@c5 = Character.new(@space, "NPC", Animations.player(self), [80, 225, 0])
		@c6 = Character.new(@space, "NPC", Animations.player(self), [80, 225, 0])
		@c7 = Character.new(@space, "NPC", Animations.player(self), [70, 200, 0])
		@c8 = Character.new(@space, "NPC", Animations.player(self), [120, 200, 0])
		@c9 = Character.new(@space, "NPC", Animations.player(self), [50, 225, 0])
		@c10 = Character.new(@space, "NPC", Animations.player(self), [80, 225, 0])
		@c11 = Character.new(@space, "NPC", Animations.player(self), [80, 225, 0])
		@c12 = Character.new(@space, "NPC", Animations.player(self), [80, 225, 0])
		@c13 = Character.new(@space, "NPC", Animations.player(self), [80, 225, 0])
		@c14 = Character.new(@space, "NPC", Animations.player(self), [80, 225, 0])
		@c15 = Character.new(@space, "NPC", Animations.player(self), [80, 225, 0])
		
		@anim = Gosu::Image::load_tiles(self, "Sprites/Fireball.png", 192, 192, false)
		@cur = @anim[0]
		
		Entity.add_all_to_space
		
		@background = Background.new(self,"Sprites/grass_texture_repeating_patter.jpg")
	end
	
	def update
		@fpscounter.update
		SUBSTEPS.times do
			@cur = @anim[Gosu::milliseconds / 100 % @anim.size]
			
			Entity.transfer_x_for_all
			Entity.reset_all
			
			@inpman.update()
			process_input
			
			Entity.apply_gravity_to_all
			Entity.update_all
			
			#~ puts "Player: #{@player.body.x}, #{@player.body.y}, #{@player.body.z}"
			
			
			@space.step
		end
	end
	
	def process_input
		dir = @inpman.direction
		if dir != nil
			if @inpman.active? :run
				@player.run dir
			else
				@player.move dir
			end
		end
		
		if @inpman.active?(:jump)
			@player.jump
		end
	end
	
	def draw
		@background.draw
		@fpscounter.draw
		
		Entity.draw_all
		#~ @cur.transparent("#000000").draw(0,0,3)
		@cur.draw(60,60,3)
		
	end
	
	def button_down(id)
		@inpman.button_down(id)
		
		if id == Gosu::Button::KbEscape
			close
		end
		if id == Gosu::Button::KbF
			@fpscounter.show_fps = !@fpscounter.show_fps
		end
	end
	
	def button_up(id)
		@inpman.button_up(id)
	end
end

class InputHandler
	def direction
		up =	self.query(:up) == :active
		down =	self.query(:down) == :active
		left =	self.query(:left) == :active
		right =	self.query(:right) == :active
		
		result = if up && left
			:up_left
		elsif up && right
			:up_right
		elsif down && left
			:down_left
		elsif down && right
			:down_right
		elsif up
			:up
		elsif down
			:down
		elsif left
			:left
		elsif right
			:right
		else
			nil #No button for direction pressed
		end

		result
	end
	
	def def_kb_bindings
		createAction(:up)
		bindAction(:up, Gosu::Button::KbUp)
		createAction(:down)
		bindAction(:down, Gosu::Button::KbDown)
		createAction(:left)
		bindAction(:left, Gosu::Button::KbLeft)
		createAction(:right)
		bindAction(:right, Gosu::Button::KbRight)
		
		createAction(:jump)
		bindAction(:jump, Gosu::Button::KbLeftShift)
		
		createAction(:run)
		bindAction(:run, Gosu::Button::KbLeftControl)
	end
	
	def active?(action)
		self.query(action) == :active
	end
end

#Taken from OpenGLIntegration.rb from the gosu tutorials
#Remove/replace later with code to generate the real background
#Using this as a test to be able to see stuff more clearly.
class GLBackground
  # Height map size
  POINTS_X = 7
  POINTS_Y = 7
  # Scrolling speed
  SCROLLS_PER_STEP = 50

  def initialize(window)
    @image = Gosu::Image.new(window, "./Sprites/grass_texture.png", true)
    @scrolls = 0
    @height_map = Array.new(POINTS_Y) { Array.new(POINTS_X) { rand } }
  end
  
  def scroll
    @scrolls += 1
    if @scrolls == SCROLLS_PER_STEP then
      @scrolls = 0
      @height_map.shift
      @height_map.push Array.new(POINTS_X) { rand }
    end
  end
  
  def exec_gl
    # Get the name of the OpenGL texture the Image resides on, and the
    # u/v coordinates of the rect it occupies.
    # gl_tex_info can return nil if the image was too large to fit onto
    # a single OpenGL texture and was internally split up.
    info = @image.gl_tex_info
    return unless info

    # Pretty straightforward OpenGL code.
    
    glDepthFunc(GL_GEQUAL)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_BLEND)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    glFrustum(-0.10, 0.10, -0.075, 0.075, 1, 100)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    glTranslate(0, 0, -4)
  
    glEnable(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, info.tex_name)
    
    offs_y = 1.0 * @scrolls / SCROLLS_PER_STEP
    
    0.upto(POINTS_Y - 2) do |y|
      0.upto(POINTS_X - 2) do |x|
        glBegin(GL_TRIANGLE_STRIP)
          z = @height_map[y][x]
          glColor4d(1, 1, 1, z)
          glTexCoord2d(info.left, info.top)
          glVertex3d(-0.5 + (x - 0.0) / (POINTS_X-1), -0.5 + (y - offs_y - 0.0) / (POINTS_Y-2), z)

          z = @height_map[y+1][x]
          glColor4d(1, 1, 1, z)
          glTexCoord2d(info.left, info.bottom)
          glVertex3d(-0.5 + (x - 0.0) / (POINTS_X-1), -0.5 + (y - offs_y + 1.0) / (POINTS_Y-2), z)
        
          z = @height_map[y][x + 1]
          glColor4d(1, 1, 1, z)
          glTexCoord2d(info.right, info.top)
          glVertex3d(-0.5 + (x + 1.0) / (POINTS_X-1), -0.5 + (y - offs_y - 0.0) / (POINTS_Y-2), z)

          z = @height_map[y+1][x + 1]
          glColor4d(1, 1, 1, z)
          glTexCoord2d(info.right, info.bottom)
          glVertex3d(-0.5 + (x + 1.0) / (POINTS_X-1), -0.5 + (y - offs_y + 1.0) / (POINTS_Y-2), z)
        glEnd
      end
    end
  end
end

Game_Window.new.show
