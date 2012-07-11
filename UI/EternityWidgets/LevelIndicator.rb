class LevelIndicator < Widget::Div
	def initialize(window, x,y, options={})
		options = 	{
			:z_index => 0,
			:relative => window,
			:align => :left,
			
			:position => :static, # static, dynamic, relative
			
			:width => 1,
			:width_units => :px,
			:height => 1,
			:height_units => :px,
			
			:background_color => Gosu::Color::BLUE,
			
			:padding_top => 0,
			:padding_bottom => 0,
			:padding_left => 0,
			:padding_right => 0,
			
			# Positioning
			:top => 0,
			:bottom => 0,
			:left => 0,
			:right => 0
		}.merge! options
		
		@level_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/levelgear.png", false
		options[:width] = @level_gear.width
		options[:height] = @level_gear.height
		
		super(window, x,y, options)
		
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
		
		@level = Widget::Label.new window, 0, 0,
				:relative => self,
				:width => :auto, :height => @font.height,
				
				:top => :auto,	:bottom => :auto,
				:left => 0,		:right => 0,
				
				:background_color => Gosu::Color::NONE,
				
				:text => "", :font => @font, :color => Gosu::Color::RED,
				:text_align => :center, :vertical_align => :middle
		
		
	end
	
	def update(level)
		super()
		@level.text = "#{level}"
	end
	
	def draw
		super()
		@level_gear.draw self.render_x, self.render_y, @pz
		@level.draw
	end
end
