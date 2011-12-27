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
				:text => "TITLE", :font => @font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom
		
		@name_box = Widget::TextField.new window, 0,40,
				:relative => @sidebar,
				:background_color => Gosu::Color::WHITE,
				:width => 100, :width_units => :percent, :height => @font.height,
				:text => "enter level name", :font => @font, :color => Gosu::Color::BLUE
		
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
				puts "hey"
				puts Physics::Direction::Y_HAT
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
		
		
		add_gameobject @sidebar
		add_gameobject @sidebar_title
		add_gameobject @name_box
		add_gameobject @load
		add_gameobject @save
		add_gameobject @flatten
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
end
