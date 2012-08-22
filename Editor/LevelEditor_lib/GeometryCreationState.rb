class GeometryCreationstate < LevelEditorInterface
	def initialize(window, space, font, inpman)
		super(window, space, font, inpman)
		init_widgets window
		
		#~ @new_rect = 
		@pos1 = CP::Vec2.new 0,0
		
		#~ init_scene_inputs inpman, :editor
		#~ bind_scene_inputs inpman, :editor

		@pos2 = CP::Vec2.new 0,0
	end
	
	def update
		super()
	end
	
	def draw
		if @now_drawing
			draw_rect
		end
		
		@sidebar.draw
		@sidebar_title.draw
		@point1.draw
		@point2.draw
		@position1.draw
		@position2.draw
	end

	def button_down(id)
		
	end
	
	def button_up(id)

	end
	
	def in_menu?
		return (@window.mouse_x >= @sidebar.body.p.x)
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
			
		projections = {
			:trimetric_projection => Widget::Button.new(window,
				:relative => @sidebar,

				:top => 40, :bottom => :auto,
				:left => 100, :right => :auto,
				
				:width => 80, :height => @font.height,
				:font => @font, :text => "Trimetric", :color => Gosu::Color::BLACK
				
			) do

			end,
			
			:screen_projection => Widget::Button.new(window,
				:relative => @sidebar,

				:top => 40, :bottom => :auto,
				:left => 100, :right => :auto,
				
				:width => 80, :height => @font.height,
				:font => @font, :text => "Screen", :color => Gosu::Color::BLACK
				
			) do

			end			
		}
	
	end

	def init_scene_inputs(inpman, state_name)
		super(inpman, state_name)
		inpman.mode = :create
		
		inpman.new_action :start_rect, :rising_edge do
			@pos1.x = @window.mouse_x
			@pos1.y = @window.mouse_y
		end
		
		inpman.new_action :creating_rect, :active do
			@pos2.x = @window.mouse_x
			@pos2.y = @window.mouse_y
			@now_drawing = true		
		end
		
		inpman.new_action :finish_rect, :falling_edge do
			@now_drawing = false
			#create rectangle entity for pos1 and pos2
			@pos1 = nil
			@pos2 = nil
			
		end
		
	end
	
	def bind_scene_inputs(inpman, state_name)
		super(inpman, state_name)
		
		inpman.bind_action :move_object, Gosu::MsLeft
		
		#~ inpman.bind_action :place_cursor, Gosu::MsLeft
	end
	
	def draw_rect
		#use @pos1 and @pos2
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
