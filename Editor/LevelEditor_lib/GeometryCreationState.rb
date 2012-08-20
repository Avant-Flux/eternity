class GeometryCreationstate < LevelEditorInterface
	def initialize(window, space, font)
		super(window, space, font)
		
		init_widgets window
		
		@button_width = 80
		@active_mode = :default
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
				:left => 86, :right => :auto,
				
				:width => @button_width, :height => @font.height,
				:font => @font, :text => "Create", :color => Gosu::Color::BLACK)
			do 
				switch_to_mode :create
			end
			
			:edit => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => 3, :bottom => :auto,
				:left => 166, :right => :auto,
				
				:width => @button_width, :height => @font.height,
				:font => @font, :text => "Edit", :color => Gosu::Color::BLACK)
			do 
				switch_to_mode :edit
			end
			
			:spawn => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => 3, :bottom => :auto,
				:left => 249, :right => :auto,
				
				:width => @button_width, :height => @font.height,
				:font => @font, :text => "Spawn", :color => Gosu::Color::BLACK)
			do 
				switch_to_mode :spawn
			end
			
			:default => Widget::Button.new(window,
				:relative => @sidebar,
				
				:top => 3, :bottom => :auto,
				:left => 332, :right => :auto,
				
				:width => @button_width, :height => @font.height,
				:font => @font, :text => "Default", :color => Gosu::Color::WHITE)
			do 
				switch_to_mode :default
			end
		}
	
	end
	
	def click_create()
		if @create_mode
			@create_mode = false
			@create.color = Gosu::Color::BLACK
		else 
			@create_mode = true
			@create.color = Gosu::Color::WHITE
		end
	end
	
	def switch_to_mode(new_mode)
		@modes[@active_mode].color = Gosu::Color::BLACK
		@modes[new_mode].color = Gosu::Color::WHITE
		
		@active_mode = new_mode
	end
end
