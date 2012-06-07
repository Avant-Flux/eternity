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

include Gl
include Glu


class GameWindow < Gosu::Window
	attr_accessor :camera
	
	def initialize
		@target_fps = 60
		# Window should have a 16:9 aspect ratio
		super(1280, 720, false, (1.0/@target_fps)*1000)
		self.caption = "Eternity 0.11.2"
		
		@tile_width = 5
		@tile_height = 5
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		
		@player = Player.new self
		
		@camera = Camera.new self
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
		if id == Gosu::KbA
			@steppable = true
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
		
		if id == Gosu::KbA
			@steppable = false
		end
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
end
