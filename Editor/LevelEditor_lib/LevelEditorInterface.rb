class LevelEditorInterface < InterfaceState
	attr_reader :mouse
	
	def initialize(window, space, layers, name, open, close)
		super(window, space, layers, name, open, close)
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		space.set_default_collision_func do
			false
		end
		
		@mouse = MouseHandler.new space, layers
		
		sidebar_width = 250
		@sidebar = Widget::Div.new window, window.width-sidebar_width,0,
				:width => sidebar_width, :height => 100, :height_units => :percent,
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
			puts "load"
			
			begin
				@state = open.call LevelState, @name_box.text
				@name_box.editable = false
			rescue
				@name_box.reset
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
		
		# Generate a "flat" version of the current level,
		# similar to a cross section, or a top-down view.
		@flatten = Widget::Button.new window, 0,110,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Flatten", :font => @font, :color => Gosu::Color::BLUE do
			puts "Flatten"
			
			begin
				
			rescue
				puts "Error generating flattened data"
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
		create_draw_options window
		
		
		add_gameobject @sidebar
		add_gameobject @sidebar_title
		add_gameobject @name_box
		add_gameobject @load
		add_gameobject @save
		add_gameobject @flatten
		
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
		
		@draw_options.each_value do |widget|
			add_gameobject widget
		end
		
		#~ add_gameobject @export_uvs
		#~ @sidebar.add_to space
		#~ @load.add_to space
		#~ @save.add_to space
	end
	
	def update
		super
	end
	
	def draw
		@gameobjects.each do |obj|
			obj.draw
		end
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
		
		x_field = @position_controls[:x][1]
		def x_field.on_click
			puts "Meh~"
		end
		
		y_field = @position_controls[:y][1]
		def y_field.on_click
			puts "Meh~"
		end
		
		z_field = @position_controls[:z][1]
		def z_field.on_click
			puts "Meh~"
		end
	end
	
	def create_dimension_controls(window)
		@dimension_controls = Hash.new
		
		# Set base position from which all elemnets are structured
		x = 120
		y = window.height - 150
		
		vert_offset = 30
		
		[:w, :d, :h].each_with_index do |axis, i|
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
	
	def create_property_control_buttons(window)
		y = window.height - 50
		
		@confirm_changes = Widget::Button.new window, 0,y,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Confirm", :font => @font, :color => Gosu::Color::BLUE do
			begin
				puts "confirm"
			rescue
				puts "Error: Properties not saved"
			end
			
			#~ @gc = true
		end
		
		@cancel_changes = Widget::Button.new window, 120,y,
				:relative => @sidebar, :width => 100, :height => 30,
				:background_color => Gosu::Color::WHITE,
				:text => "Cancel", :font => @font, :color => Gosu::Color::BLUE do
			begin
				puts "cancel"
			rescue
				puts "Error: Cancel failed"
			end
			
			#~ @gc = true
		end
	end
	
	def create_draw_options(window)
		x = 0
		y = 150
		
		vert_offset = 35
		
		@draw_options = {
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
					puts "Wireframe"
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
					puts "Faces"
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
					puts "Flattened"
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
					puts "Grid"
				rescue
					puts "Error: Grid can not be displayed"
				end
				
				#~ @gc = true
			end
		}
	end
end
