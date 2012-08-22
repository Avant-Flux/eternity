class LevelEditorInterface
	attr_reader :mouse, :width
	attr_reader :sidebar
	
	def initialize(window, space, font)
		@window = window
		@space = space
		@font = font
		
		@temp_var = Entity.new @window
		@temp_var.shape.collision_type = :none
		@temp_var.body.p.x = @window.state_manager.top.spawn[0]
		@temp_var.body.p.y = @window.state_manager.top.spawn[1]
		@temp_var.body.pz = @window.state_manager.top.spawn[2]
		@window.camera.followed_entity = @temp_var
	end
	
	def update
		if in_menu?
			@window.selected_cursor = :menu
			@window.inpman.mode = :editor_menu
		end
	end
	
	def draw
		
	end
	
	# If scroll events are fixed in input handler, #buton_up/down can be removed.
	def button_up(id)
		
	end
	
	def button_down(id)
	
	end
	
	def click(mouse_x,mouse_y)
		# TODO: Click events should only trigger for UI widget with highest z index
		@space.point_query CP::Vec2.new(mouse_x,mouse_y) do |target|
			if target.gameobject.respond_to? :on_click 
				puts "target: #{target.gameobject}"
				target.gameobject.on_click
			end
		end
	end
	
	# Return true if the cursor is over the UI element.  Should be defined by all children.
	def in_menu?
		false
	end
	
	private
	
	def add_to_space(widget)
		@space.add_static_shape widget.shape
	end
	
	def remove_from_space(widget)
		@space.remove_static_shape widget.shape
	end
	
	def init_scene_inputs(inpman, state_name)
		inpman.mode = state_name
		
		inpman.new_action :set_pan, :rising_edge do
			@old_mouse = @window.state_manager.raycast @window.mouse_x,@window.mouse_y
		end
		
		inpman.new_action :pan, :active do
			@cur_mouse = @window.state_manager.raycast @window.mouse_x,@window.mouse_y
			dif_x = @cur_mouse.x - @old_mouse.x
			dif_y = @cur_mouse.y - @old_mouse.y

			@temp_var.body.p.x = @temp_var.body.p.x - dif_x
			@temp_var.body.p.y = @temp_var.body.p.y - dif_y
		end
		
		inpman.new_action :select_object, :rising_edge do
			@pos_mouse = @window.state_manager.raycast @window.mouse_x, @window.mouse_y
			
			closest_shape = nil
			@window.state_manager.raycast_mouse do |shape| 
				closest_shape ||= shape
				if shape.body.pz > closest_shape.body.pz
					closest_shape = shape
				end
				@selected_building = closest_shape				
			end
		end
		
		inpman.new_action :msleft_up, :falling_edge do
			@selected_building = nil
			@window.state_manager.rehash_space
		end
	end
	
	def bind_scene_inputs(inpman, state_name)
		inpman.mode = state_name
		
		inpman.bind_action :pan, Gosu::MsMiddle
		inpman.bind_action :set_pan, Gosu::MsMiddle
		
		inpman.bind_action :select_object, Gosu::MsLeft
		
		inpman.bind_action :msleft_up, Gosu::MsLeft
	end
	
	def init_ui_inputs(inpman, state_name)
		inpman.mode = state_name
		
		inpman.new_action :menu_click, :rising_edge do
			self.click(@window.mouse_x, @window.mouse_y)
		end
	end
	
	def bind_ui_inputs(inpman, state_name)
		inpman.mode = state_name
		inpman.bind_action :menu_click, Gosu::MsLeft
	end
end
