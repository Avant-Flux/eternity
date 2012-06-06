class LevelEditorInterface
	attr_reader :mouse, :width
	
	def initialize(window, space)
		@window = window
		@space = space
		
		#~ @grid = grid
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		space.set_default_collision_func do
			false
		end
		
		#~ @mouse = MouseHandler.new space
		
		width = 250
		@sidebar = Widget::Div.new window, window.width-width,0,
				:width => width, :height => 100, :height_units => :percent,
				:background_color => Gosu::Color::WHITE,
				:padding_top => 10, :padding_bottom => 10, :padding_left => 10, :padding_right => 10
		
		@sidebar_title = Widget::Label.new window, 0,0,
				:relative => @sidebar, :width => @sidebar.width, :height => 30,
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
				@name_box.editable = false
			rescue
				#~ @name_box.reset
				#~ @name_box.text = "File not found"
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
	end
	
	def update
		
	end
	
	def draw
		@sidebar.draw
		@sidebar_title.draw
		@name_box.draw
		@load.draw
		@save.draw
	end
end
