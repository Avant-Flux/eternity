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
			:placement => PlacementState.new(@window, @space, @font)#,
			#~ :geometry_creation => GeometryCreationstate.new(@window, @space, @font)
		}
		
		@active = :placement
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
		@active = state
		# TODO: Remove old state from space
		# TODO: Add new state to space
	end
	
	def over_UI?(mouse_x, mouse_y)
		mouse_x >= @states[@active].sidebar.body.p.x
	end
end
