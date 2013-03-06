#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
# require "bundler/setup"

require 'oni'
require 'chipmunk'
require 'algorithms'

require 'require_all'
#~ require 'profile'

require_all './Utilities'

require_all './Physics'

# require_all './Combat'
# require_all './Drawing'
# require_all './Equipment'
# require_all './Stats'
# require_all './Titles'

# require_all './GameObjects'
# require_all './GameStates'

# require_all './UI'

require './GameObjects/Entity'
require './GameObjects/StaticObject'
	require './GameObjects/Components/Physics'
	require './GameObjects/Components/Movement'
	require './GameObjects/Components/Model'
	require './GameObjects/Components/Combat'

require './GameStates/LevelState'

require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu
include Glut


class GameWindow < Oni::Window
	# attr_accessor :camera, :show_fps
	# attr_reader :state_manager, :ui_state_manager
	
	def setup
		# @target_fps = 60
		# Window should have a 16:9 aspect ratio
		# super(1280, 720, false, (1.0/@target_fps)*1000)
		# self.caption = "Eternity 0.11.5"
		# @show_fps = false
		
		# @font = Gosu::Font.new self, "Trebuchet MS", 25
		
		# @player = Player.new self
		
		# @state_manager = StateManager.new self, @player
		# @ui_state_manager = UI_StateManager.new self, @player, @state_manager
		
		# # Input manager holds the only other reference to the camera
		# # other than this window.  Thus, if the camera get changed,
		# # it will break the ability of the input to affect the camera.
		# @inpman = EternityInput.new self, @player, @camera, @state_manager, @ui_state_manager
		
		@camera = Oni::Camera.new(self, "main_camera", 0) # TODO: Make z_order=0 by default
		
		@camera.fov = 110
		
		scale = 2
		
		r = 3*scale
		angle = 17.degrees
		
		x = r*Math.sin(angle)
		z = r*Math.cos(angle)
		
		@offset = [x,3.5*scale,z]
		@camera.position = @offset

		@camera.look_at [0,0,0]
		@camera.near_clip_distance = 1
		
		
		@crab = Oni::Model.new(self, "Crab", "Crab.mesh")
		# @player = Oni::Agent.new(self, "Human_Male", "Human_Male.mesh")
		@player = Entity.new self, "Human_Male", "Human_Male"
		# @player.translate 0, 0, 0
		
		# @player.animation = "my_animation"
		# @player.base_animation = "walkywalky"
		# @player.top_animation = "flippyfloppy"
		
		
		
		@inpman = EternityInput.new self, @player, @camera
		
		@space = Physics::Space.new
		@space.add_collision_handler :entity, :static, CollisionHandler::EntityEnv.new
		
		
		@player.physics.body.p = CP::Vec2.new(-10,0) # Origin is occupied by colliding objects
		@player.physics.add_to @space # TODO: Change interface
		# @space.add @player
		
		
		@level = LevelState.load self, @space, "Scrapyard" 
		# @level = LevelState.load self, @space, "Room" 
		@level.add_to @space
	end
	
	def update(dt)
		# puts dt
		
		@space.update dt
		@inpman.update # process_input
		
		# #~ puts @player.body.p
		# #~ @player.body.reset_forces
		# @state_manager.update # Update the entities within the active state
		
		# @ui_state_manager.update
		@level.update dt
		
		@player.update dt
		
		pos = @offset.clone
		pos[0] += @player.physics.body.p.x
		pos[1] += @player.physics.body.pz
		pos[2] += -@player.physics.body.p.y
		@camera.position = pos
		
		
		# puts @player.physics.body.v.length
	end
	
	def draw
		# # Draw gameworld state
		# @state_manager.draw
		
		# # Draw screen-relative "flat" elements (UI etc)
		# @ui_state_manager.draw
		
		# if @show_fps
		# 	@font.draw "FPS: #{Gosu::fps}", 10,10,10, 1,1, Gosu::Color::FUCHSIA
		# end
	end
	
	def button_down(id)
		# # Part of the update loop, not event-driven
		@inpman.button_down(id)
		
		# if id == Gosu::MsWheelDown
		# 	@state_manager.camera.zoom_out
		# elsif id == Gosu::MsWheelUp
		# 	@state_manager.camera.zoom_in
		# end
	end
	
	def button_up(id)
		# # Part of the update loop, not event-driven
		@inpman.button_up(id)
	end
	
	# def needs_cursor?
	# 	true
	# end
end
