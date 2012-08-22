class GeometryCreationstate < LevelEditorInterface
	def initialize(window, space, font, inpman)
		super(window, space, font)
		init_widgets window
		
		@pos1 = CP::Vec2.new 0,0
		
		init_ui_inputs inpman, :editor_menu
		bind_ui_inputs inpman, :editor_menu
		init_scene_inputs inpman, :editor
		bind_scene_inputs inpman, :editor
	end
	
	def update

	end
	
	def draw
		@sidebar.draw
		@sidebar_title.draw
		@point1.draw
		@point2.draw
		@position1.draw
		@position2.draw
	end

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
			
			:font => @font, :text => "Geometry Creation", :color => Gosu::Color::WHITE,
			
			:background_color => Gosu::Color::BLACK
			
		@point1 = Widget::Label.new window,
			:relative => @sidebar,
			
			:top => 40, :bottom => :auto,
			:left => 10, :right => :auto,
			
			:width => 80, :height => @font.height,
			:font => @font, :text => "Point 1: ", :color => Gosu::Color::BLACK
			
		@point2 = Widget::Label.new window,
			:relative => @sidebar,
			
			:top => 80, :bottom => :auto,
			:left => 10, :right => :auto,
			
			:width => 80, :height => @font.height,
			:font => @font, :text => "Point 2: ", :color => Gosu::Color::BLACK
		
		@position1 = Widget::Label.new window,
			:relative => @sidebar,
			
			:top => 40, :bottom => :auto,
			:left => 100, :right => :auto,
			
			:width => 80, :height => @font.height,
			:font => @font, :text => "text", :color => Gosu::Color::BLACK
		
		@position2 = Widget::Label.new window,
			:relative => @sidebar,
			
			:top => 80, :bottom => :auto,
			:left => 100, :right => :auto,
			
			:width => 80, :height => @font.height,
			:font => @font, :text => "text", :color => Gosu::Color::BLACK
	
	end
	
	def button_up(id)
		
	end
	
	def button_down(id)
	
	end
	
	{
		:add_widgets_to_space => :add_to_space,
		:remove_widgets_from_space => :remove_from_space,
	}.each do |interface_method, backend_method|
		define_method interface_method do
			self.send backend_method, @sidebar
			self.send backend_method, @sidebar_title	
			self.send backend_method, @point1
			self.send backend_method, @point2
			self.send backend_method, @position1
			self.send backend_method, @position2
		end
	end

end
