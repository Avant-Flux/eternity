class PlacementState < LevelEditorInterface
	attr_reader :mouse, :width
	attr_reader :sidebar
	
	def initialize(window, space, font, inpman)
		super(window, space, font)
		
		#~ @mouse = MouseHandler.new space
		init_widgets window
		
		
		init_ui_inputs inpman
		bind_ui_inputs inpman
		init_scene_inputs inpman
		bind_scene_inputs inpman
		
		@active_tab = :static
	end
	
	def update
		if @window.mouse_x >= @sidebar.body.p.x
			@window.selected_cursor = :menu
			@window.inpman.mode = :editor_menu
		else
			@window.inpman.mode = :editor
		end
		
		@gameobject_selector_panel[@active_tab].update
	end
	
	def draw
		@sidebar.draw
		@sidebar_title.draw
		@tabs.each_value {|tab| tab.draw}
		@gameobject_selector_panel[@active_tab].draw
		
		@filepath.draw
		#~ @name_box.draw
		@load.draw
		@save.draw
	end
	
	def button_down(id)
		case id
			when Gosu::MsWheelDown
				if @window.button_down? Gosu::MsLeft
					if @seleted_building
						@selected_building.body.pz -= 1
					end
				else
					@window.camera.zoom_in
				end
			when Gosu::MsWheelUp
				if @window.button_down? Gosu::MsLeft
					if @seleted_building
						@selected_building.body.pz += 1
					end
				else
					@window.camera.zoom_out
				end
		end
	end
	
	def button_up(id)
		
	end
	
	private
	
	def init_widgets(window)
		@sidebar = Widget::Div.new	window,
			:relative => window,
			
			:top => 0, :bottom => 0,
			:left => :auto, :right => 0,
			
			:width => 300, :height => :auto,
			
			:background_color => Gosu::Color.rgba(255,255,255, 100)
		@sidebar_title = Widget::Label.new window,
			:relative => @sidebar,
			
			:top => 0, :bottom => :auto,
			:left => :auto, :right => :auto,
			
			:width => 200, :height => @font.height,
			
			:font => @font, :text => "Object type", :color => Gosu::Color::WHITE,
			
			:background_color => Gosu::Color::BLACK
		
		tab_vert_offset = 30
		@tabs = {
			:static => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => tab_vert_offset, :bottom => :auto,
				:left => 5, :right => :auto,
				
				:width => 97, :height => @font.height,
				
				:font => @font, :text => "Static", :color => Gosu::Color::WHITE
				
			) do
				switch_to_tab :static
				@gameobject_selector_panel[:static].list_static_objects
			end,
			
			
			:entity => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => tab_vert_offset, :bottom => :auto,
				:left => :auto, :right => :auto,
				
				:width => 97, :height => @font.height,
				
				:font => @font, :text => "Entity", :color => Gosu::Color::BLACK

			) do

				switch_to_tab :entity
				@gameobject_selector_panel[:entity].list_entity_objects

			end,
			
			
			:spawn => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => tab_vert_offset, :bottom => :auto,
				:left => :auto, :right => 5,
				
				:width => 97, :height => @font.height,
				
				:font => @font, :text => "Spawn", :color => Gosu::Color::BLACK

			) do
				switch_to_tab :spawn
				@gameobject_selector_panel[:spawn].list_spawn
			end
		}
		
		offset_y = 55
		@gameobject_selector_panel = {
			:static => StaticObjectPanel.new(window, @sidebar, offset_y),
			:entity => EntityPanel.new(window, @sidebar, offset_y),
			:spawn => SpawnPanel.new(window, @sidebar, offset_y)
		}
		
		# Set color of tabs to match the panels
		@gameobject_selector_panel.each do |type, panel|
			panel.background_color.alpha = 100
			@tabs[type].background_color = panel.background_color
		end
		
		@filepath = Widget::TextField.new window,
			:relative => @sidebar,
			
			:top => :auto, :bottom => 70,
			:left => :auto, :right => :auto,
			
			:width => 200, :height => @font.height,
			:font => @font, :text => "Filename: #{@window.state_manager.top.name}", :color => Gosu::Color::WHITE,
			
			:background_color => Gosu::Color::BLACK
		
		@save = Widget::Button.new window,
			:relative => @sidebar,
			
			:top => :auto, :bottom => 30,
			:left => 10, :right => :auto,
			
			:width => 100, :height => @font.height,
			:font => @font, :text => "Save", :color => Gosu::Color::BLACK do
			
			# Save click event
			# Save current level to path specified by @filepath widget
			
		end
		
		@load = Widget::Button.new window,
			:relative => @sidebar,
			
			:top => :auto, :bottom => 30,
			:left => :auto, :right => 10,
			
			:width => 100, :height => @font.height,
			:font => @font, :text => "Load", :color => Gosu::Color::BLACK do
			# Load click event
			# Load file specified in @filepath widget
			
		end
	end
	
	def init_scene_inputs(inpman)
		inpman.mode = :editor
		
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
		
		inpman.new_action :move_object, :active do
			unless @window.button_down?(Gosu::KbLeftControl) || @window.button_down?(Gosu::KbRightControl)
				@cur_mouse = @window.state_manager.raycast @window.mouse_x,@window.mouse_y
				dif_x = @cur_mouse.x - @pos_mouse.x
				dif_y = @cur_mouse.y - @pos_mouse.y
				
				if @selected_building
					@selected_building.body.p.x = @selected_building.body.p.x + dif_x
					@selected_building.body.p.y = @selected_building.body.p.y + dif_y
				end
				
				@pos_mouse = @cur_mouse
			end
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
		
		inpman.new_action :place_cursor, :active do
			@selected_cursor = :place #if @selected_cursor == :default
		end
	end
	
	def bind_scene_inputs(inpman)
		inpman.mode = :editor
		
		inpman.bind_action :pan, Gosu::MsMiddle
		inpman.bind_action :set_pan, Gosu::MsMiddle
		#~ @inpman.bind_action :test2, Gosu::MsMiddle
		
		inpman.bind_action :select_object, Gosu::MsLeft
		inpman.bind_action :move_object, Gosu::MsLeft
		inpman.bind_action :msleft_up, Gosu::MsLeft
		
		inpman.bind_action :place_cursor, Gosu::MsLeft
	end
	
	def init_ui_inputs(inpman)
		inpman.mode = :editor_menu
		
		inpman.new_action :menu_click, :rising_edge do
			self.click(@window.mouse_x, @window.mouse_y)
		end
	end
	
	def bind_ui_inputs(inpman)
		inpman.mode = :editor_menu
		inpman.bind_action :menu_click, Gosu::MsLeft
	end
	
	def switch_to_tab(new_tab)
		@tabs[@active_tab].color = Gosu::Color::BLACK
		@tabs[new_tab].color = Gosu::Color::WHITE
		
		@active_tab = new_tab
	end

	{
		:add_widgets_to_space => :add_to_space,
		:remove_widgets_from_space => :remove_from_space,
	}.each do |interface_method, backend_method|
		define_method interface_method do
			self.send backend_method, @sidebar
			self.send backend_method, @sidebar_title
			self.send backend_method, @save
			self.send backend_method, @load
			self.send backend_method, @filepath
			@tabs.each_value do |tab|
				self.send backend_method, tab
			end
			@gameobject_selector_panel.each_value do |panel|
				self.send backend_method, panel
			end
			
		end
	end
	
end
