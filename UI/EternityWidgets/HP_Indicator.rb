class HP_Indicator < Widget::Div
	def initialize(window, x,y, options={})
		@font = Gosu::Font.new window, "Helvetica Bold", 25
		
		@health_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/hpgear.png", false
		options[:width] = @health_gear.width
		options[:height] = @health_gear.height
		
		super(window, x,y, options)
		
		heath_label_offset_x = 80
		width = 50
		x = (@window.width/2)+heath_label_offset_x
		y = @window.height - 60 -20
		@hp_label = Widget::Label.new window, 0,0,
						:relative => self,
						:width => width, :height => @font.height,
						
						:margin_left => 100,	:margin_left_units => :percent,
						:margin_top => 10,		:margin_top_units => :px,
						
						:top => :auto,			:bottom => :auto,
						:left => 0,			:right => :auto,
						
						:text => "HP", :font => @font, :color => Gosu::Color::RED,
						:text_align => :center, :vertical_align => :bottom,
						
						:background_color => Gosu::Color::YELLOW
		
		heath_label_offset_x = 10
		width = 100
		x = (@window.width/2) + heath_label_offset_x
		y = @window.height - 35
		@hp_numerical_display = Widget::Label.new window, 0,0,
									:relative => self,
									:width => width, :height => @font.height,
									
									:margin_top => 100, :margin_top_units => :percent,
									
									:top => 0,			:bottom => :auto,
									:left => -5,		:right => :auto,
									
									:text => "", :font => @font, :color => Gosu::Color::RED,
									:text_align => :center, :vertical_align => :top,
									
									:background_color => Gosu::Color::NONE
	end
	
	def update(hp, max_hp)
		@hp_numerical_display.text = "#{hp} | #{max_hp}"
	end
	
	def draw
		super()
		scale_side_gears = 0.25
		#~ side_gear_offset_x = 55
		side_gear_offset_x = 48
		side_gear_offset_y = 45+40+20
		
		# Health
		# Red fill
		@health_gear.draw self.render_x, self.render_y, @pz
		
		@hp_label.draw
		# Health level (text)
		@hp_numerical_display.draw
	end
end

