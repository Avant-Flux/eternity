class LevelEditorInterface < InterfaceState
	attr_reader :mouse, :width
	
	def initialize(window, space, layers, name, open, close, grid)
		super(window, space, layers, name, open, close)
		@grid = grid
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		space.set_default_collision_func do
			false
		end
		
		@mouse = MouseHandler.new space, layers
		
		@width = 250
		@sidebar = Widget::Div.new window, window.width-width,0,
				:width => width, :height => 100, :height_units => :percent,
				:background_color => Gosu::Color::BLUE,
				:padding_top => 10, :padding_bottom => 10, :padding_left => 10, :padding_right => 10
		
		@sidebar_title = Widget::Label.new window, 0,0,
				:relative => @sidebar, :width => @sidebar.width(:meters), :height => 30,
				:background_color => Gosu::Color::NONE,
				:text => "File", :font => @font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom
		
		@name_box = Widget::TextField.new window, 0,40,
				:relative => @sidebar,
				:background_color => Gosu::Color::WHITE,
				:width => 100, :width_units => :percent, :height => @font.height,
				:text => "enter level name", :initial_temp_text => true,
				:font => @font, :color => Gosu::Color::BLUE
		
		@load = Widget::Button.new window, 0,70,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Load", :font => @font, :color => Gosu::Color::BLUE do
			begin
				@state = open.call LevelState, @name_box.text
				#~ @name_box.editable = false
			rescue
				#~ @name_box.reset
				@name_box.text = "File not found"
			end
			
			
			#~ @open.call 
			#~ @gc = true
		end
		
		@save = Widget::Button.new window, 120,70,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Save", :font => @font, :color => Gosu::Color::BLUE do
			puts "Save"
			
			begin
				close.call @name_box.text
			rescue
				puts "save error"
			end
			
			#~ @gc = true
		end
		
		#~ @export_uvs = Widget::Button.new window, 120,110,
				#~ :relative => @sidebar, :width => 100, :height => 30,
				#~ :background_color => Gosu::Color::WHITE,
				#~ :text => "Export UVs", :font => @font, :color => Gosu::Color::BLUE do
			#~ puts "Export"
			#~ 
			#~ if @state
				#~ path = File.join LevelState::LEVEL_DIRECTORY, "#{@state.name}Texures"
				#~ @state.export path
			#~ else
				#~ puts "No level to export"
			#~ end
		#~ end
		
		create_position_controls window
		create_dimension_controls window
		create_property_control_buttons window
		create_draw_option_buttons window
		create_visibility_controls window
		create_selection_controls window
		create_object_controls window
		
		add_gameobject @sidebar
		add_gameobject @sidebar_title
		add_gameobject @name_box
		add_gameobject @load
		add_gameobject @save
		
		@position_controls.each do |axis, control|
			control.each do |widget|
				add_gameobject widget
			end
		end
		
		@dimension_controls.each do |axis, control|
			control.each do |widget|
				add_gameobject widget
			end
		end
		
		add_gameobject @confirm_changes
		add_gameobject @cancel_changes
		
		@draw_option_buttons.each_value do |widget|
			add_gameobject widget
		end
		
		@visibility_controls.each_value do |widget|
			add_gameobject widget
		end
		
		@selection_controls.each_value do |widget|
			add_gameobject widget
		end
		
		@object_controls.each_value do |widget|
			add_gameobject widget
		end
		
		#~ add_gameobject @export_uvs
		#~ @sidebar.add_to space
		#~ @load.add_to space
		#~ @save.add_to space
		
		@displayed_element = nil
	end
	
	def update
		super
		
		unless @mouse.active.empty?
			if @displayed_element != @mouse.active.first
				@displayed_element = @mouse.active.first
				@position_controls[:x][1].text = @displayed_element.px_.to_s
				@position_controls[:y][1].text = @displayed_element.py_.to_s
				@position_controls[:z][1].text = @displayed_element.pz_.to_s
				
				@dimension_controls[:w][1].text = @displayed_element.width(:meters).to_s
				@dimension_controls[:d][1].text = @displayed_element.depth(:meters).to_s
				@dimension_controls[:h][1].text = @displayed_element.height(:meters).to_s
			end
		end
	end
	
	def draw
		super
	end
	
	private
	
	def create_position_controls(window)
		@position_controls = Hash.new
		
		# Set base position from which all elemnets are structured
		x = 0
		y = window.height - 150
		
		vert_offset = 30
		
		[:x, :y, :z].each_with_index do |axis, i|
			@position_controls[axis] = [
				# Create label
				Widget::Label.new(window, x,y+vert_offset*i,
				:relative => @sidebar, :width => 10, :height => @font.height,
				:background_color => Gosu::Color::NONE,
				:text => axis.to_s, :font => @font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom),
				# Create text field
				Widget::TextField.new(window, x+20,y+vert_offset*i,
				:relative => @sidebar,
				:background_color => Gosu::Color::WHITE,
				:width => 85, :height => @font.height,
				:text => "", :font => @font, :color => Gosu::Color::BLUE)
			]
		end
	end
	
	def create_dimension_controls(window)
		@dimension_controls = Hash.new
		
		# Set base position from which all elemnets are structured
		x = 120
		y = window.height - 150
		
		vert_offset = 30
		
		[:w, :d, :h].each_with_index do |axis, i|
			@dimension_controls[axis] = [
				# Create label
				Widget::Label.new(window, x,y+vert_offset*i,
				:relative => @sidebar, :width => 10, :height => @font.height,
				:background_color => Gosu::Color::NONE,
				:text => axis.to_s, :font => @font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom),
				# Create text field
				Widget::TextField.new(window, x+20,y+vert_offset*i,
				:relative => @sidebar,
				:background_color => Gosu::Color::WHITE,
				:width => 85, :height => @font.height,
				:text => "", :font => @font, :color => Gosu::Color::BLUE)
			]
		end
	end
	
	def create_property_control_buttons(window)
		y = window.height - 50
		
		@confirm_changes = Widget::Button.new window, 0,y,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Confirm", :font => @font, :color => Gosu::Color::BLUE do
			begin
				@mouse.active.each_with_index do |gameobj, i|
					# Remove current object, and create a new one of the same type
					
					# Remove current object
					@state.delete_gameobject gameobj
					
					# Extract properties from input widgets
					x = Float @position_controls[:x][1].text
					y = Float @position_controls[:y][1].text
					z = Float @position_controls[:z][1].text
					
					w = Float @dimension_controls[:w][1].text
					d = Float @dimension_controls[:d][1].text
					h = Float @dimension_controls[:h][1].text
					
					
					position = [x,y,z]
					dimensions = [w,d,h]
					
					new_obj =	if gameobj.class == Building
									Building.new @window, gameobj.name, position, dimensions
								end
					
					# Add object to space
					@state.add_gameobject new_obj
					
					@space.rehash_static
					
					# Remove old object from selection, and add new object
					@mouse.active[i] = new_obj
				end
			rescue => e
				puts "Error: Properties not saved"
			end
			
			#~ @gc = true
		end
		
		@cancel_changes = Widget::Button.new window, 120,y,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Cancel", :font => @font, :color => Gosu::Color::BLUE do
			begin
				@mouse.active_widgets.each do |widget|
					widget.on_lose_focus
				end
				@mouse.active_widgets.clear
			rescue
				puts "Error: Cancel failed"
			end
			
			#~ @gc = true
		end
	end
	
	def create_draw_option_buttons(window)
		x = 0
		y = 100
		
		vert_offset = 35
		
		@draw_option_buttons = {
			:title => Widget::Label.new( window, x,y,
				:relative => @sidebar, :width => @sidebar.width(:meters), :height => 30,
				:background_color => Gosu::Color::NONE,
				:text => "View", :font => @font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom),
			:wireframe => Widget::Button.new(window, 0,y+vert_offset,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Wireframe", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					Wireframe::Box.show_wireframe = !Wireframe::Box.show_wireframe
				rescue
					puts "Error: Wireframe can not be rendered"
				end
				
				#~ @gc = true
			end,
			:faces => Widget::Button.new( window, 120,y+vert_offset,
					:relative => @sidebar, :width => 100, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "Faces", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					Wireframe::Box.show_faces = !Wireframe::Box.show_faces
				rescue
					puts "Error: Faces of geometry can not be rendered"
				end
				
				#~ @gc = true
			end,
			:flattened => Widget::Button.new( window, 0,y+vert_offset*2,
					:relative => @sidebar, :width => 100, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "Flattened", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					Wireframe::Box.show_flattened = !Wireframe::Box.show_flattened
				rescue
					puts "Error: Flattened view can not be displayed"
				end
				
				#~ @gc = true
			end,
			:grid => Widget::Button.new( window, 120,y+vert_offset*2,
					:relative => @sidebar, :width => 100, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "Grid", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					@grid.visible = !@grid.visible?
				rescue
					puts "Error: Grid can not be displayed"
				end
				
				#~ @gc = true
			end
		}
	end
	
	def create_visibility_controls(window)
		x = 0
		y = 200
		
		vert_offset = 35
		
		@visibility_controls = {
			:title => Widget::Label.new( window, x,y,
				:relative => @sidebar, :width => @sidebar.width(:meters), :height => 30,
				:background_color => Gosu::Color::NONE,
				:text => "Visibility controls", :font => @font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom),
			
			:on => Widget::Button.new( window, 0,y+vert_offset,
					:relative => @sidebar, :width => 100, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "Show all", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					Wireframe::Box.show_only_selected = false
				rescue
					puts "Error: Failed to make all wireframes visible"
				end
				
				#~ @gc = true
			end,
			
			:only_selected => Widget::Button.new( window, 120,y+vert_offset,
					:relative => @sidebar, :width => 100, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "Selected", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					Wireframe::Box.show_only_selected = true
				rescue
					puts "Error: Can not toggle \"only selected\" option"
				end
				
				#~ @gc = true
			end,
		}
	end
	
	def create_selection_controls(window)
		x = 0
		y = 260
		
		vert_offset = 35
		
		@selection_controls = {
			:title => Widget::Label.new( window, x,y,
				:relative => @sidebar, :width => @sidebar.width(:meters), :height => 30,
				:background_color => Gosu::Color::NONE,
				:text => "Selection controls", :font => @font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom),
			
			:all => Widget::Button.new( window, 0,y+vert_offset,
					:relative => @sidebar, :width => 50, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "All", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					Wireframe::Box.all.each do |wireframe|
						wireframe.selected = true
					end
				rescue
					puts "Error: Can not select all object"
				end
				
				#~ @gc = true
			end,
			:none => Widget::Button.new( window, 60,y+vert_offset,
					:relative => @sidebar, :width => 50, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "None", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					Wireframe::Box.all.each do |wireframe|
						wireframe.selected = false
					end
				rescue
					puts "Error: Can not deselect all objects"
				end
				
				#~ @gc = true
			end,
			:invert => Widget::Button.new( window, 120,y+vert_offset,
					:relative => @sidebar, :width => 100, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "Invert", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					Wireframe::Box.all.each do |wireframe|
						wireframe.selected = !wireframe.selected
					end
				rescue
					puts "Error: Can not deselect all objects"
				end
				
				#~ @gc = true
			end
		}
	end
	
	def create_object_controls(window)
		# Buttons to create and destroy objects
		x = 0
		y = 320
		
		vert_offset = 35
		
		@object_controls = {
			:title => Widget::Label.new( window, x,y,
				:relative => @sidebar, :width => @sidebar.width(:meters), :height => 30,
				:background_color => Gosu::Color::NONE,
				:text => "Object controls", :font => @font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom),
				
			:delete => Widget::Button.new( window, 0,y+vert_offset,
					:relative => @sidebar, :width => 100, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "Delete Obj", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					@mouse.active.each_with_index do |gameobj, i|
						@state.delete_gameobject gameobj
					end
				rescue
					puts "Error: Object could not be deleted"
				end
				
				#~ @gc = true
			end,
			
			:new_building => Widget::Button.new( window, 0,y+vert_offset*2,
					:relative => @sidebar, :width => 100, :height => 30,
					:background_color => Gosu::Color::WHITE,
					:text => "New Bldg", :font => @font, :color => Gosu::Color::BLUE) do
				begin
					puts "Making new Building"
					position = [0,0,0]
					dimensions = [1,1,1]
					building = Building.new @window, "NAME_1", position, dimensions
					@state.add_gameobject building
					
					@mouse.deselect_gameobject
					@mouse.select_gameobject building
				rescue
					puts "Error: Could not create new building"
				end
				
				#~ @gc = true
			end
		}
	end
end
