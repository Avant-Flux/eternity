#!/usr/bin/ruby

# Define a stack structure to hold game states
# and allow them to be processed
# 	Each game state is defined by a GameState object which has the methods
# 	of a Gosu::Window object.  The Gosu::Window will in turn loop over
# 	all GameState objects and call the appropriate methods.
class GameStateManager
	UPPER = 0
	LOWER = 1
	MENU = 2

	def initialize(window, camera)
		@window = window
		@camera = camera
		
		# Keep track of what chipmunk layer to contain things on
		@layer = 0
		
		# Set up physics space
		@space = Physics::Space.new 1/60.0
		@space.iterations = 10
		@steppable = true
		
		# Use an array as a psudo hash to reduce cost
		# UPPER		Will not draw
		# LOWER		Will draw and update
		# This structure is used to help with multi-level structures,
		# such as buildings and caves.
		@stack = Array.new(3)
		@stack[UPPER] = []
		@stack[LOWER] = []
		@stack[MENU] = []
				
		# Keep UI layer separate, so that the UI is always drawn on top
		# of all states in the LOWER stack
		@ui_state = InterfaceState.new @window, @space, @layer, "HUD"
		@layer += 1
	end
	
	# Draw all contained gamestates
	def draw
		# Draw each state, followed by a flush
		# Thus, each gamestate can have it's own z-ordering system
		@stack[LOWER].each do |gamestate|
			if gamestate.visible?
				gamestate.draw
				@window.flush
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
	
	# Update all contained gamestates
	# The LOWER gamestates will update from low to high, but the 
	# UPPER gamestates update from high to low, in terms of
	# Z-Index.
	def update
		@stack.each do |stack|
		stack.each do |gamestate|
			if gamestate.update?
				gamestate.update
			end
		end; end
		
		@ui_state.update
	end
	
	# Create a new gamestate and place it on the LOWER stack
	def new_gamestate(klass, name, *args)
		@layer += 1
		
		args = [@window, @space, @layer, name].concat args
		gamestate = klass.new *args
		
		@stack[LOWER] << gamestate
	end
	
	# Create a new gamestate and place it on the UPPER stack
	def load_gamestate(klass, name)
		@layer += 1
		
		args = [@window, @space, @layer, name]
		args << @camera if klass == LevelState
		gamestate = klass.new *args
		
		@stack[UPPER] << gamestate
	end
	
	# Remove the state from the stack system
	def delete(name)
		@stack.each do |stack|
			if state = stack.delete(name)
				state.finalize
				# Make it so the layer number used by this gamestate
				# is once again viable to be used.
			end
		end
	end
	
	# Move the state on the top of the LOWER stack to the UPPER stack
	def stash(iter=1)
		iter.times do
			@stack[UPPER] << @stack[LOWER].pop
		end
	end
	
	# Move the state on the top of the UPPER stack to the LOWER stack
	def restore(iter=1)
		iter.times do
			@stack[LOWER] << @stack[UPPER].pop
		end
	end
	
	# Push a given gamestate onto the stack
	def push(gamestate)
		@stack[LOWER] << gamestate
	end
	alias :<< :push
	
	# Pop the gamestate off of the stack
	def pop
		@stack[LOWER].pop
	end
	
	# Place the player into the game environment
	def add_player(player)
		@player = player
		@stack[LOWER]
	end
end

