class Sidebar < Widget::Div
	def initialize(window, space, font, title, width, options={})
		options =	{
						:background_color => Gosu::Color::BLUE,
						
						:width => width,
						:height => 100,
						:height_units => :percent,
						
						:padding_top => 50,
						:padding_bottom => 30,
						:padding_left => 30,
						:padding_right => 30
					}.merge! options
		
		super window, window.width-width, 0, options
		
		@font = font
		@title = Widget::Label.new window, -20,-40,
				:relative => self, :width => 100, :height => 30,
				:background_color => Gosu::Color::NONE,
				:text => title, :font => font, :color => Gosu::Color::BLACK,
				:text_align => :left, :vertical_align => :bottom
	end
	
	def update
		
	end
	
	def draw
		super
		@title.draw
	end
	
	def on_click
		puts "been clicked: #{self.class}"
	end
	
	[:add_to, :remove_from].each do |method|
		define_method method do |space|
			super space
			@title.send method, space
		end
	end
end
