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
		@space = Physics::Space.new @window.update_interval/1000, -9.8, 1
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
				
		# Set up collision handlers
		init_collision_handlers
		
		@pause = false
		
		# Generate a new interface
		@open_prompt = lambda do |klass, name|
			#~ puts "opening! from #{self}"
			#~ self.new_prompt
			#~ self.clear_levels
			new_level klass, name
		end
		
		# Close the interface and return associated data
		@close_prompt = lambda do |name|
			@stack[ACTIVE].each_with_index do |state, i|
				if state.name == name
					state.save
					state.gc = true
				end
			end
			
			#~ data = self.delete_prompt name
			#~ return data
		end
		
		# Create mouse handler
		@mouse = MouseHandler.new @space
	end
	
	# Update all contained gamestates
	# The LOWER gamestates will update from low to high, but the 
	# UPPER gamestates update from high to low, in terms of
	# Z-Index.
	def update
		if !@pause
			@space.step
			
			[@stack[HIDDEN], @stack[ACTIVE]].each_with_index do |stack, i|
			stack.each do |gamestate|
				if gamestate.gc
					delete_at stack, i
				elsif gamestate.update?
					gamestate.update
				end
			end; end
			
			if @player.pz > 0
				@camera.arial_camera_add @player
			end
		end
		
		@stack[MENU].each_with_index do |gamestate, i|
			if gamestate.gc
				#~ gamestate.gc = false
				
				#~ gamestate.gameobjects.each do |obj|
					#~ obj.remove_from @space
				#~ end
				#~ gamestate.gameobjects[0].remove_from @space
				#~ gamestate.gameobjects[1].remove_from @space
				#~ gamestate.gameobjects[2].remove_from @space
				#~ gamestate.gameobjects[3].remove_from @space
				
				#~ gamestate.finalize
				#~ 
				#~ state = @stack[MENU].delete gamestate
				
				delete_at @stack[MENU], i
				#~ puts "#{deleted_state} vs #{gamestate}"
			elsif gamestate.update?
				gamestate.update
			end
		end
	end
	
	# Draw all contained gamestates
	def draw
		# Draw each state, followed by a flush
		# Thus, each gamestate can have it's own z-ordering system
		
		
		@window.translate *@camera.offset do
			@stack[ACTIVE].each do |gamestate|
				if gamestate.visible?
					gamestate.draw @camera
					@window.flush
				end
			end
		end
		
		# ===== DEBUG SYMBOLS
		#~ @window.translate *@camera.offset do
			#~ @space.all.each do |obj|
				#~ gameobject = obj.gameobj
				#~ unless gameobject.is_a? Camera
					#~ gameobject.draw @camera.zoom, @player, @camera.vertex_absolute(0)
				#~ end
			#~ end
		#~ end
		# ===== END DEBUG SYMBOLS
		
		#~ @stack[ACTIVE].each do |gamestate|
			#~ if gamestate.visible?
				#~ @window.translate *@camera.offset do
					#~ gamestate.draw @camera.zoom
				#~ end
				#~ 
				#~ @window.flush
			#~ end
		#~ end
		
		@stack[MENU].each do |menu|
			if menu.visible?
				menu.draw
				@window.flush
			end
		end
	end
	
	# Create a new gamestate and place it on the LOWER stack
	def new_level(klass, name, *args)
		layer = new_layer
		args = [@window, @space, layer, name, @camera[layer], *args]
		
		gamestate =  if klass.ancestors.include? LevelState
						klass.load *args
					else
						klass.new *args
					end
		
		@stack[ACTIVE] << gamestate
		
		return gamestate
	end
	
	# Create a new gamestate and place it on the UPPER stack
	def load_gamestate(klass, name)
		layer = new_layer
		args = [@window, @space, layer, name]
		args << @camera[layer] if klass == LevelState
		gamestate = klass.new *args
		
		@stack[HIDDEN] << gamestate
	end
	
	# Create a new gamestate and place it on the LOWER stack
	def new_gamestate(klass, name)
		layer = new_layer
		args = [@window, @space, layer, name]
		args << @camera[layer] if klass == LevelState
		gamestate = klass.new *args
		
		@stack[ACTIVE] << gamestate
		
		return gamestate
	end
	
	def clear_levels
		@stack[ACTIVE].each do |state|
			state.finalize
			layer = delete_layer state
			
			# Must clear the camera as well
			@camera[layer].clear
		end
		@stack[ACTIVE].clear
	end
	
	# Generates a new interface state and adds it to the stack
	def new_interface(klass, name, player=nil)
		unless klass.ancestors.include? InterfaceState
			raise ArgumentError, "Provided class object not an interface"
		end
		
		args = [@window, @space, UI_LAYER, name, @open_prompt, @close_prompt]
		args << player if player
		
		interface = klass.new *args
		@stack[MENU] << interface
		
		interface
	end
	
	def new_prompt
		new_interface PromptState, "Prompt"
	end
	
	def delete_prompt(name)
		return nil
	end
	
	# Remove the state from the stack system
	def delete(name)
		@stack.each do |stack|
			if state = stack.delete(name)
				state.finalize
				layer = delete_layer state
				@camera[layer].clear
			end
		end
	end
	
	def delete_at(stack, i)
		state = stack.delete_at i
		state.finalize
		layer = delete_layer state
		@camera[layer].clear
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
		@stack[ACTIVE].last.add_player player
	end
	
	def toggle_menu
		pause
		
		if @stack[MENU].last.is_a? UI_State
			new_interface MenuState, "Menu", @player
		else
			until @stack[MENU].last.is_a? UI_State
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
		#~ state.gameobjects.each do |obj|
			#~ obj.remove_from @space
		#~ end
		@layers << state.layers
		return state.layers
	end
	
	def init_collision_handlers
		entity_handler = CollisionHandler::Entity.new
		entity_env_handler = CollisionHandler::EntityEnv.new
		entity_env_top_handler = CollisionHandler::EntityEnvTop.new
		camera_collision = CollisionHandler::Camera.new
		
		@space.add_collision_handler :entity, :environment, entity_env_handler
		@space.add_collision_handler :entity, :building, entity_env_handler
		
		@space.add_collision_handler :entity, :environment_top, entity_env_top_handler
		@space.add_collision_handler :entity, :building_top, entity_env_top_handler
		
		
		@space.add_collision_handler :entity, :entity, entity_handler
		
		[:entity, :building_render_object, :environment_render_object].each do |type|
			@space.add_collision_handler :camera, type, camera_collision
		end
	end
end

