#!/usr/bin/ruby

# Define a stack structure to hold game states
# and allow them to be processed
# 	Each game state is defined by a GameState object which has the methods
# 	of a Gosu::Window object.  The Gosu::Window will in turn loop over
# 	all GameState objects and call the appropriate methods.
class GameStateManager
	HIDDEN = 0
	ACTIVE = 1
	MENU = 2
	
	CAMERA_LAYER = 0x1
	UI_LAYER = 0x2

	def initialize(window, camera, player)
		@window = window
		@player = player
		@camera = camera
		@camera.layers = CP::ALL_LAYERS ^ UI_LAYER # All layers except for the UI
		
		# Layers
		# first layer			0x1						objects which help manage the camera
		# second layer			0x2						UI Objects
		# subsequent layers		0x4 - 0x80000000		objects from various game states
		
		# Keep track of what chipmunk layer to contain things on
		@layers = [0x4]
		# Possible potential for a memory leak, if the stack continues to grow
		# Try to use a linked list instead
		
		# Set up physics space
		@space = Physics::Space.new @window.update_interval/1000, -9.8, 0.05
		@space.iterations = 10
		@steppable = true
		
		# Use an array as a psudo hash to reduce cost
		# HIDDEN		Will not draw
		# ACTIVE		Will draw and update
		# MENU		Contains all menu states
		# This structure is used to help with multi-level structures,
		# such as buildings and caves.
		@stack = Array.new(3)
		@stack[HIDDEN] = []
		@stack[ACTIVE] = []
		@stack[MENU] = []
		
		# Add camera to the space
		@camera.add_to @space
				
		# Keep UI layer separate, so that the UI is always drawn on top
		# of all states in the LOWER stack
		@ui_state = UI_State.new @window, @space, UI_LAYER, "HUD", @player
		
		# Set up collision handlers
		init_collision_handlers
		
		@pause = false
	end
	
	# Update all contained gamestates
	# The LOWER gamestates will update from low to high, but the 
	# UPPER gamestates update from high to low, in terms of
	# Z-Index.
	def update
		if !@pause
			@space.step
			
			[@stack[HIDDEN], @stack[ACTIVE]].each do |stack|
			stack.each do |gamestate|
				if gamestate.update?
					gamestate.update
				end
			end; end
		
			@ui_state.update
		end
		
		@stack[MENU].each do |gamestate|
			if gamestate.update?
				gamestate.update
			end
		end
	end
	
	# Draw all contained gamestates
	def draw
		# Draw each state, followed by a flush
		# Thus, each gamestate can have it's own z-ordering system
		
		# TODO correct translation calculation
		@window.translate *@camera.offset do
			@stack[ACTIVE].each do |gamestate|
				if gamestate.visible?
					gamestate.draw @camera.zoom
					@window.flush
				end
			end
		end
		
		@ui_state.draw
		@window.flush
		
		@stack[MENU].each do |menu|
			if menu.visible?
				menu.draw
				@window.flush
			end
		end
	end
	
	# Create a new gamestate and place it on the LOWER stack
	def new_gamestate(klass, name)
		layer = new_layer
		args = [@window, @space, layer, name]
		args << @camera[layer] if klass == LevelState
		gamestate = klass.new *args
		
		@stack[ACTIVE] << gamestate
	end
	
	# Create a new gamestate and place it on the UPPER stack
	def load_gamestate(klass, name)
		layer = new_layer
		args = [@window, @space, layer, name]
		args << @camera[layer] if klass == LevelState
		gamestate = klass.new *args
		
		@stack[HIDDEN] << gamestate
	end
	
	# Remove the state from the stack system
	def delete(name)
		@stack.each do |stack|
			if state = stack.delete(name)
				state.finalize
				delete_layer state
			end
		end
	end
	
	# Move the state on the top of the LOWER stack to the UPPER stack
	def stash(iter=1)
		iter.times do
			@stack[HIDDEN] << @stack[LOWER].pop
		end
	end
	
	# Move the state on the top of the UPPER stack to the LOWER stack
	def restore(iter=1)
		iter.times do
			@stack[ACTIVE] << @stack[UPPER].pop
		end
	end
	
	# Push a given gamestate onto the stack
	def push(gamestate)
		@stack[ACTIVE] << gamestate
	end
	alias :<< :push
	
	# Pop the gamestate off of the stack
	def pop
		@stack[ACTIVE].pop
	end
	
	# Pause the state of the game
	# If the game is already paused, will resume game
	def pause
		@pause = !@pause
	end
	
	# Returns true if the active gamestates are not being updated
	def pause?
		@pause
	end
	
	# Place the player into the game environment
	def add_player(player)
		@player = player
		@stack[ACTIVE].last.add_gameobject player
	end
	
	def toggle_menu
		pause
		
		if @stack[MENU].empty?
			@stack[MENU] << MenuState.new(@window, @space, new_layer, "Menu", @player)
		else
			until @stack[MENU].empty?
				state = @stack[MENU].pop
				state.finalize
				delete_layer state
			end
		end
	end
	
	def menu_active?
		!@stack[MENU].empty?
	end
	
	private
	
	# Return the number for a new layer
	def new_layer
		layer = @layers.pop
		if @layers.empty?
			next_layer = layer << 1
			if next_layer > CP::ALL_LAYERS
				raise RangeError, "Maximum number of layers exceeded"
			else
				@layers << next_layer
			end
		end
		
		layer
	end
	
	# Delete the layer with the given number,
	# and allow the number to be used again.
	def delete_layer(state)
		# Remove all Chipmunk objects with the given layer
		state.gameobjects.each do |obj|
			obj.remove_from @space
		end
		@layers << state.layers
	end
	
	def init_collision_handlers
		entity_handler = CollisionHandler::Entity.new
		entity_env_handler = CollisionHandler::Entity_Env.new
		camera_collision = CollisionHandler::Camera.new
		
		@space.add_collision_handler :entity, :environment, entity_env_handler
		@space.add_collision_handler :entity, :building, entity_env_handler
		@space.add_collision_handler :entity, :entity, entity_handler
		
		[:entity, :building, :environment].each do |type|
			@space.add_collision_handler :camera, type, camera_collision
		end
	end
end

