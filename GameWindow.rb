#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require "bundler/setup"

require 'gosu'
require 'chipmunk'
require 'algorithms'

require 'require_all'
#~ require 'profile'
#~ require 'ruby-prof'
#~ RubyProf.start

require_all './Utilities'

require_all './Physics'

require_all './Combat'
require_all './Drawing'
require_all './Equipment'
require_all './Stats'
require_all './Titles'

require_all './GameObjects'
require_all './GameStates'

require_all './UI'

require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu
include Glut


class GameWindow < Gosu::Window
	attr_accessor :camera
	
	def initialize
		@target_fps = 60
		# Window should have a 16:9 aspect ratio
		super(1280, 720, false, (1.0/@target_fps)*1000)
		self.caption = "Eternity 0.11.4"
		
		@tile_width = 5
		@tile_height = 5
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		
		@player = Player.new self
		
		@camera = Camera::TrimetricCamera.new self
		@camera.followed_entity = @player
		
		
		@state_manager = StateManager.new self, @player
		@ui_state_manager = UI_StateManager.new self, @player, @state_manager
		
		# Input manager holds the only other reference to the camera
		# other than this window.  Thus, if the camera get changed,
		# it will break the ability of the input to affect the camera.
		@inpman = EternityInput.new @player, @camera, @state_manager, @ui_state_manager
	end
	
	def update
		# process_input
		@inpman.update
		
		#~ puts @player.body.p
		#~ @player.body.reset_forces
		@state_manager.update # Update the entities within the active state
		
		@ui_state_manager.update
	end
	
	def draw
		# Draw gameworld state
		@state_manager.draw
		
		# Draw screen-relative "flat" elements (UI etc)
		@ui_state_manager.draw
		
		if @show_fps
			@font.draw "FPS: #{Gosu::fps}", 10,10,10, 1,1, Gosu::Color::FUCHSIA
		end
	end
	
	def button_down(id)
		# Part of the update loop, not event-driven
		@inpman.button_down(id)
		
		if id == Gosu::KbEscape
			close
		end
		if id == Gosu::KbF
			@show_fps = !@show_fps
		end
		
		if id == Gosu::MsWheelDown
			@camera.zoom_in
		elsif id == Gosu::MsWheelUp
			@camera.zoom_out
		end
	end
	
	def button_up(id)
		# Part of the update loop, not event-driven
		@inpman.button_up(id)
	end
	
	def needs_cursor?()
		true
	end
	
	def draw_circle(x,y,z, r, color, options={})
		options = {
			:stroke_width => 1,	# Width of the line
			:slices => 30, # Number of subdivisions around the z axis.
			:loops => 1, # Number of concentric rings about the origin.
			
			:start_angle => 0,
			
			:alpha => 1 # Float value
		}.merge! options
		
		self.gl z do
			@quadric ||= gluNewQuadric()
			
			glEnable(GL_BLEND)
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
			
			glColor4f(color.red, color.green, color.blue, options[:alpha])
			glTranslatef(x,y,0)
			
			# Given Gosu's coordinate system, 0deg is down, pos rotation is CCW
			gluPartialDisk(@quadric, r-options[:stroke_width], r, 
							options[:slices], options[:loops],
							options[:start_angle], 360)
		end
	end
	
	# Utilize OpenGL's stencil buffer to perform functionality similar to masks
	# in Photoshop.
	# Precondition:	Mask is a lambda which draws into the buffer
	#				Z is the z-index of the calls.  Think more scheduling than depth test.
	# 				The implicit block parameter is the code to be drawn "behind" the mask
	def stencil(mask, z=0, &block)
		# NOTE:	Super NOT threadsafe.  Entire method must be run at once, to insure proper 
		# 		z-indexing.  Gosu is currently not threadsafe anyway, so this is not a problem.
		# 		However, if the engine does become threadsafe, know that there needs to be 
		# 		a barrier around this method, or similar.
		#
		# gl blocks introduce new context where Gosu calls can not be used.
		# NOTE: This means that no Gosu calls can be used within this method
		#~ puts "stencil buffer bitplanes: #{glGetIntegerv(GL_STENCIL_BITS)}"
		no_planes = 0x0
		# Generate bitvectory of the length of GL_STENCIL_BITS
		#~ all_planes = 0x1
		#~ (glGetIntegerv(GL_STENCIL_BITS)-1).times do
			#~ all_planes >> 1
			#~ all_planes += 0x1
		#~ end
		#~ puts all_planes.to_s 2
		all_planes = 0xff
		#~ puts all_planes.to_s 2
		#~ all_planes = 0x7
		
		
		
		self.gl z do
			# === Much code taken from the wikibooks OpenGl Stencil Buffer page
			glutInitDisplayMode(GLUT_RGBA|GLUT_ALPHA|GLUT_DOUBLE|GLUT_DEPTH|GLUT_STENCIL)

			glClear(GL_DEPTH_BUFFER_BIT)

			# Enable stencil buffer
			glEnable(GL_STENCIL_TEST)
			
			# Disable color and depth buffers
			glColorMask(false, false, false, false)
			glDepthMask(false)
			
			glStencilFunc(GL_NEVER, 1, all_planes)
			glStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP) # Draw 1s on test fail (always)
			
			# Draw stencil pattern
			glStencilMask(all_planes)
			glClear(GL_STENCIL_BUFFER_BIT)
			
			# ===== Draw mask
			mask.call
			
			# Re-enable color and depth buffers
			glColorMask(true, true, true, true)
			glDepthMask(true)
			glStencilMask(no_planes)
			
			# Draw where stencil's value is 0
			glStencilFunc(GL_EQUAL, 0, all_planes)
			## (nothing to draw)
			
			# Draw only where stencil's value is 1
			glStencilFunc(GL_EQUAL, 1, all_planes)
			
			# ===== Draw the actual stuff
			#~ mask.call
			block.call
			
			# Turn stencil buffer off
			glDisable(GL_STENCIL_TEST)
		end
	end
end
