class LevelEditorInterface
	attr_reader :mouse, :width
	attr_reader :sidebar
	
	def initialize(window)
		@window = window
		@space = CP::Space.new # Just for UI stuff
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		#~ space.set_default_collision_func do
			#~ false
		#~ end
		
		#~ @mouse = MouseHandler.new space
		init_widgets window
		
		add_to_space @sidebar
		add_to_space @sidebar_title
		@tabs.each_value {|tab| add_to_space tab}
		@gameobject_selector_panel.each_value {|panel| add_to_space panel} 
		add_to_space @save
		add_to_space @load
		add_to_space @filepath
		
		@active_tab = :static
	end
	
	def update
		if @window.mouse_x >= @sidebar.body.p.x
			@window.selected_cursor = :menu
		end
		
		@gameobject_selector_panel[@active_tab].update
		
	end
	
	def draw
		@compass.draw
		
		@sidebar.draw
		@sidebar_title.draw
		@tabs.each_value {|tab| tab.draw}
		@gameobject_selector_panel[@active_tab].draw
		
		@filepath.draw
		#~ @name_box.draw
		@load.draw
		@save.draw
	end
	
	def click(mouse_x,mouse_y)
		@space.point_query CP::Vec2.new(mouse_x,mouse_y) do |target|
		
			if target.gameobject.respond_to? :on_click 
				puts "target: #{target.gameobject}"
				target.gameobject.on_click
			end
		end
	end
	
	private
	
	def init_widgets(window)
		@compass = Compass.new	window,
			:relative => window,
			
			:top => :auto, :bottom => 20,
			:left => 20, :right => :auto
		
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
			end,
			
			
			:spawn => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => tab_vert_offset, :bottom => :auto,
				:left => :auto, :right => 5,
				
				:width => 97, :height => @font.height,
				
				:font => @font, :text => "Spawn", :color => Gosu::Color::BLACK

			) do
				switch_to_tab :spawn
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
	
	def switch_to_tab(new_tab)
		@tabs[@active_tab].color = Gosu::Color::BLACK
		@tabs[new_tab].color = Gosu::Color::WHITE
		
		@active_tab = new_tab
	end
	
	def add_to_space(widget)
		@space.add_static_shape widget.shape
	end
	
end
