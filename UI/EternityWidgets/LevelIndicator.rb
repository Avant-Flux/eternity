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
		
		super(window, x,y, options)
		
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
		
		width = 50
		@level = Widget::Label.new window, (window.width - width)/2, 25,
				:width => width, :height => @font.height,
				#~ :background_color => Gosu::Color::FUCHSIA,
				:text => "", :font => @font, :color => Gosu::Color::RED,
				:text_align => :center, :vertical_align => :bottom
		
		@level_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/levelgear.png", false
	end
	
	def update(level)
		super()
		@level.text = "#{level}"
	end
	
	def draw
		super()
		x = @window.width/2 - @level_gear.width/2
		y = 10
		z = 100
		@level_gear.draw x,y,z
		@level.draw
	end
end
