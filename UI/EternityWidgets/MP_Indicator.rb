class MP_Indicator < Widget::Div
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
		@font = font
		
		# Background
		@mana_gear = Gosu::Image.new window, 
					"./Development/Interface/interface720/mpgear.png", false
		
		
		heath_label_offset_x = 80
		width = 50
		x = (@window.width/2 - width)-heath_label_offset_x
		y = @window.height - 60 - 20
		@label = Widget::Label.new window, x,y,
					:width => width, :height => @font.height,
					#~ :background_color => Gosu::Color::GREEN,
					:text => "MP", :font => @font, :color => Gosu::Color::RED,
					:text_align => :center, :vertical_align => :top
		
		heath_label_offset_x = 10
		width = 100
		x = (@window.width/2 - width) - heath_label_offset_x
		y = @window.height - 35
		z = 100
		@numerical_display = Widget::Label.new window, x,y,
								:width => width, :height => @font.height,
								#~ :background_color => Gosu::Color::FUCHSIA,
								:text => "", :font => @font, :color => Gosu::Color::RED,
								:text_align => :center, :vertical_align => :top
	end
	
	def update
		
	end
	
	def draw
		
	end
end

