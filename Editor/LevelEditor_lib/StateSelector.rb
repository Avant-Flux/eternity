class StateSelector < LevelEditorInterface
	def initialize(window, space, font, state_manger)
		super(window, space, font)
		
		init_widgets window
		
		@button_width = 80
		@button_space = 3
		@active_mode = :default
		
		@state_manager = state_manager
	end
	
	def update
		if @window.mouse_y <= (@topbar.body.p.y + @topbar.height)
			@window.selected_cursor = :menu
		end
	end
	
	def draw
		@topbar.draw
		@topbar_title.draw
		@create.draw
		
	end
	
	def init_widgets(window)
	
		@topbar = Widget::Div.new	window,
			:relative => window,
			
			:top => 0, :bottom => :auto,
			:left => 0, :right => :auto,
			
			:width => :auto, :height => @font.height+6,
			
			:background_color => Gosu::Color.rgba(255,255,255, 100)
			
		@topbar_title = Widget::Label.new window,
			:relative => @sidebar,
			
			:top => 3, :bottom => :auto,
			:left => 3, :right => :auto,
			
			:width => @button_width, :height => @font.height,
			
			:font => @font, :text => "Modes:", :color => Gosu::Color::WHITE,
			
			:background_color => Gosu::Color::BLACK
			
		@modes = {
				
			:create => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => 3, :bottom => :auto,
				:left => (2*@button_space+@button_width), :right => :auto,
				
				:width => @button_width, :height => @font.height,
				:font => @font, :text => "Create", :color => Gosu::Color::BLACK)
			do 
				switch_to_mode :create
			end,
			
			:edit => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => 3, :bottom => :auto,
				:left => (3*@button_space+2*@button_width), :right => :auto,
				
				:width => @button_width, :height => @font.height,
				:font => @font, :text => "Edit", :color => Gosu::Color::BLACK)
			do 
				switch_to_mode :edit
			end,
			
			:spawn => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => 3, :bottom => :auto,
				:left => (4*@button_space+3*@button_width), :right => :auto,
				
				:width => @button_width, :height => @font.height,
				:font => @font, :text => "Spawn", :color => Gosu::Color::BLACK)
			do 
				switch_to_mode :spawn
			end,
			
			:default => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => 3, :bottom => :auto,
				:left => (5*@button_space+4*@button_width), :right => :auto,
				
				:width => @button_width, :height => @font.height,
				:font => @font, :text => "Default", :color => Gosu::Color::WHITE)
			do 
				switch_to_mode :default
			end
		}
	
	end
	
	def switch_to_mode(new_mode)
		@modes[@active_mode].color = Gosu::Color::BLACK
		@modes[new_mode].color = Gosu::Color::WHITE
		
		@active_mode = new_mode
	end
end
