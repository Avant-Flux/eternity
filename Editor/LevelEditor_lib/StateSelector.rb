class StateSelector
	def initialize
		@create = Widget::Button.new window,
			:relative => @sidebar,
			
			:top => :auto, :bottom => 110,
			:left => 10, :right => :auto,
			
			:width => 100, :height => @font.height,
			:font => @font, :text => "Create", :color => Gosu::Color::BLACK do 
				if @create_mode
					@create_mode = false
					@create.color = Gosu::Color::BLACK
				else 
					@create_mode = true
					@create.color = Gosu::Color::WHITE
				end
			end
	end
end
