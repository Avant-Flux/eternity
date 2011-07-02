#!/usr/bin/ruby

# Defines the behavior that a game state should respond to.
class GameState
	attr_reader :name
	
	SAVE_PATH = "./Saves"
	
	def initialize(window, space, layer, name, visible=true, update=true)
		@window = window	# Reference to a Gosu::Window object
		@space = space		# Reference to a Chipmunk space
		@layer = layer		# What layer to use in the chipmunk space
		@name = name		# An identifier for this gamestate
		
		@update = update
		@visible = visible
	end
	
	# Update the gamestate for the next frame.
	# The update rate is controlled by the Gosu::Window
	def update
		
	end
	
	# Render the gamestate to the screen
	def draw
		
	end
	
	# Stuff to do when the gamestate leaves the stack
	def finalize
		
	end
	
	# Toggle updating of the gamestate
	def pause
		@update = !@update
	end
	
	# Return true if the gamestate should be updated.
	# If false, this state is paused.
	def update?
		@update
	end
	
	# Return true if this state should be drawn to the screen.
	# It is possible for a state to only update and not draw.
	def visible?
		@visible
	end
	
	# Save data to disk.  Differs from a dump as only the info
	# needed to replicate the data is saved, not the data itself.
	def save
		
	end
	
	# Load data from disk
	def load
		
	end
	
	class << self
		# If the method is not defined here, see if it is defined for Gosu::Window
		# If it is, execute the method within the context of the window.
		def method_missing?(method_sym, *args, &block)
			if @window.respond_to? method_sym, false
				@window.send method_sym, *args, &block
			else
				super(method_sym, *args, &block)
			end
		end
	end
end
