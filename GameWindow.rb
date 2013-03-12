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


require './GameObjects/Entity'
require './GameObjects/StaticObject'
	require './GameObjects/Components/Physics'
	require './GameObjects/Components/Movement'
	require './GameObjects/Components/Model'
	require './GameObjects/Components/Combat'
require './GameObjects/Creatures/Crab'

require './GameStates/LevelState'

require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu
include Glut


class GameWindow < Oni::Window
	def setup
		# @target_fps = 60
		# Window should have a 16:9 aspect ratio
		# super(1280, 720, false, (1.0/@target_fps)*1000)
		# self.caption = "Eternity 0.11.5"
		# @show_fps = false
		
		# @state_manager = StateManager.new self, @player
		# @ui_state_manager = UI_StateManager.new self, @player, @state_manager
		
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
		
		
		@crab = Crab.new self
		@player = Entity.new self, "Human_Male", "Human_Male"
		
		# Input manager holds the only other reference to the camera
		# other than this window.  Thus, if the camera get changed,
		# it will break the ability of the input to affect the camera.
		@inpman = EternityInput.new self, @player, @camera
		
		@space = Physics::Space.new
		@space.add_collision_handler :entity, :static, CollisionHandler::EntityEnv.new
		@space.add_collision_handler :entity, :entity, CollisionHandler::Entity.new
		
		# @player.physics.add_to @space # This works too
		@space.add @player
		@space.add @crab
		

		@level_stack = []
		@level_stack << LevelState.load(self, @space, "Scrapyard")
		@level_stack.last.add_to @space
	end
	
	def update(dt)
		# puts dt
		
		@space.update dt
		@inpman.update # process_input
		
		# @state_manager.update # Update the entities within the active state
		
		# @ui_state_manager.update
		@level_stack.each do |state|
			state.update dt
		end
		
		@player.update dt
		@crab.update dt
		
		pos = @offset.clone
		pos[0] += @player.physics.body.p.x
		pos[1] += @player.physics.body.pz
		pos[2] += -@player.physics.body.p.y
		@camera.position = pos
		
		
		# puts @player.physics.body.v.length
	end
	
	def draw
		
	end
	
	def button_down(id)
		# # Part of the update loop, not event-driven
		@inpman.button_down(id)
		
		# if id == Gosu::MsWheelDown
		# 	@state_manager.camera.zoom_out
		# elsif id == Gosu::MsWheelUp
		# 	@state_manager.camera.zoom_in
		# end
		
		case id
			when 2 # Button 1
				@level_stack.pop.remove_from @space
				@level_stack << LevelState.load(self, @space, "Scrapyard")
				@level_stack.last.add_to @space
			when 3 # Button 2
				@level_stack.pop.remove_from @space
				@level_stack << LevelState.load(self, @space, "Room")
				@level_stack.last.add_to @space
			when 4 # Button 3
				@level_stack.pop.remove_from @space
				@level_stack << LevelState.load(self, @space, "FireTown")
				@level_stack.last.add_to @space
			when 5 # Button 4
				@level_stack.pop.remove_from @space
				@level_stack << LevelState.load(self, @space, "Museum")
				@level_stack.last.add_to @space
		end
	end
	
	def button_up(id)
		# # Part of the update loop, not event-driven
		@inpman.button_up(id)
	end
	
	# def needs_cursor?
	# 	true
	# end
end
