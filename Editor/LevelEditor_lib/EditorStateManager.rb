# Manages states for the level editor
class EditorStateManager
	def initialize(window)
		# TODO: Load up states instead of hard-coding
		
		@window = window
		@space = CP::Space.new # Just for UI stuff
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		#~ @space.set_default_collision_func do
			#~ false
		#~ end
		
		@selector_ui = StateSelector.new @window, @space, @font, self
		
		@states = {
			:default => PlacementState.new(@window, @space, @font),
			:edit => GeometryCreationstate.new(@window, @space, @font)
		}
		
		@active = :default
	end
	
	def update
		@states[@active].update
		@selector_ui.update
	end
	
	def draw
		@states[@active].draw
		@selector_ui.draw
	end
	
	def click(mouse_x,mouse_y)
		@states[@active].click(mouse_x,mouse_y)
		@selector_ui.click(mouse_x,mouse_y)
	end
	
	def switch_to(state)
		@states[@active].remove_widgets_from_space
		@states[state].add_widgets_to_space
		
		@active = state
	end

end
