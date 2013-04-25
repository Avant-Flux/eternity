#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require "bundler/setup"

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

require_all './Equipment'

require_all './Animation'
require_all './GameObjects/Components'

require './GameObjects/StaticObject'
require './GameObjects/Entity'
# require './GameObjects/Creatures/Crab'
require './GameObjects/Creatures/Lizard'

require './GameStates/LevelStateManager'
require './GameStates/LevelState'

# require 'gl'
# require 'glu'
# require 'glut'

# include Gl
# include Glu
# include Glut


class GameWindow < Oni::Window
	def initialize
		super("Eternity")
		# @target_fps = 60
		# Window should have a 16:9 aspect ratio
		# super(1280, 720, false, (1.0/@target_fps)*1000)
		# self.caption = "Eternity 0.11.5"
		# @show_fps = false
		
		# @state_manager = StateManager.new self, @player
		# @ui_state_manager = UI_StateManager.new self, @player, @state_manager
		
		@camera = Oni::Camera.new(self, "main_camera", 0) # TODO: Make z_order=0 by default
		
		@camera.fov = 110
		
		@scale = 2.5
		
		r = 3*@scale
		angle = 17.degrees
		
		x = r*Math.sin(angle)
		z = r*Math.cos(angle)
		
		@angle = 10.degrees
		r = 3.5*@scale
		y = r*Math.sin(@angle)
		@offset = [x,y,z]
		@camera.position = @offset
		
		@camera.look_at [0,0,0]
		@camera.near_clip_distance = 1
		
		@camera_controller = CameraController.new @camera
		
		
		# @crab = Crab.new self
		@enemies = [
			Lizard.new(self)
		]
		@player = Entity.new self, "Human_Male"
		
		# Input manager holds the only other reference to the camera
		# other than this window.  Thus, if the camera get changed,
		# it will break the ability of the input to affect the camera.
		@inpman = EternityInput.new self, @player, @camera
		
		@space = Physics::Space.new
		@space.add_collision_handler :entity, :static, CollisionHandler::EntityEnv.new
		@space.add_collision_handler :entity, :entity, CollisionHandler::Entity.new
		
		# @player.physics.add_to @space # This works too
		@space.add @player
		@enemies.each do |e|
			@space.add e
		end
		
		@level_stack = LevelStateManager.new self
		@level_stack.load @space, "Scrapyard"
	end
	
	def update(dt)
		# puts dt
		
		@space.update dt
		@inpman.update # process_input
		
		# @state_manager.update # Update the entities within the active state
		
		# @ui_state_manager.update
		@level_stack.update dt
		
		@player.update dt
		@enemies.each do |e|
			e.update dt
		end
		
		@camera_controller.update dt, @player
		# pos = @offset.clone
		# pos[0] += @player.physics.body.p.x
		# pos[1] += @player.physics.body.pz
		# pos[2] += -@player.physics.body.p.y
		# @camera.position = pos
		
		
		# puts @player.physics.body.v.length
	end
	
	def draw
		
	end
	
	def button_down(id)
		sym = button_id_to_sym(id)
		
		# Part of the update loop, not event-driven
		@inpman.button_down(sym)
		
		# if id == Gosu::MsWheelDown
		# 	@state_manager.camera.zoom_out
		# elsif id == Gosu::MsWheelUp
		# 	@state_manager.camera.zoom_in
		# end
		
		case sym
			when :kb_1
				@level_stack.load @space, "Scrapyard"
			when :kb_2
				@level_stack.load @space, "Room"
			when :kb_3
				@level_stack.load @space, "FireTown"
			when :kb_4
				@level_stack.load @space, "Museum"
		end
		
		@camera_controller.button_down(sym)
	end
	
	def button_up(id)
		sym = button_id_to_sym(id)
		
		# # Part of the update loop, not event-driven
		@inpman.button_up(sym)
		
		@camera_controller.button_up(sym)
	end
	
	# def needs_cursor?
	# 	true
	# end
end
