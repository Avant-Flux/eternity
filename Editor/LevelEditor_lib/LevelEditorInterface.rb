class LevelEditorInterface
	attr_reader :mouse, :width
	
	def initialize(window, space)
		@window = window
		@space = space
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		#~ space.set_default_collision_func do
			#~ false
		#~ end
		
		#~ @mouse = MouseHandler.new space
		init_widgets window
		
		@active_tab = :static
	end
	
	def update
		switch_to_tab :static
	end
	
	def draw
		@compass.draw
		
		@sidebar.draw
		@sidebar_title.draw
		@tabs.each_value {|tab| tab.draw}
		@gameobject_selector_panel[@active_tab].draw
		
		#~ @name_box.draw
		#~ @load.draw
		#~ @save.draw
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
			:static => Widget::Label.new(window,
				:relative => @sidebar,
				
				:top => tab_vert_offset, :bottom => :auto,
				:left => 0, :right => :auto,
				
				:width => 100, :height => @font.height,
				
				:font => @font, :text => "Static", :color => Gosu::Color::BLACK
			),
			:entity => Widget::Label.new(window,
				:relative => @sidebar,
				
				:top => tab_vert_offset, :bottom => :auto,
				:left => :auto, :right => :auto,
				
				:width => 100, :height => @font.height,
				
				:font => @font, :text => "Entity", :color => Gosu::Color::BLACK
			),
			:spawn => Widget::Label.new(window,
				:relative => @sidebar,
				
				:top => tab_vert_offset, :bottom => :auto,
				:left => :auto, :right => 0,
				
				:width => 100, :height => @font.height,
				
				:font => @font, :text => "Spawn", :color => Gosu::Color::BLACK
			)
		}
		
		offset_y = 55
		@gameobject_selector_panel = {
			:static => StaticObjectPanel.new(window, @sidebar, offset_y),
			:entity => EntityPanel.new(window, @sidebar, offset_y),
			:spawn => SpawnPanel.new(window, @sidebar, offset_y)
		}
		
		# Set color of tabs to match the panels
		@gameobject_selector_panel.each do |type, panel|
			@tabs[type].background_color = panel.background_color
		end
	end
	
	def switch_to_tab(new_tab)
		@tabs[@active_tab].color = Gosu::Color::BLACK
		@tabs[new_tab].color = Gosu::Color::WHITE
		
		@active_tab = new_tab
	end
end
