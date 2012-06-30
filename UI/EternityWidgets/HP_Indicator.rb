class HP_Indicator < Widget::Div
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
		@hp_label = Widget::Label.new window, x,y,
					:width => width, :height => @font.height,
					#~ :background_color => Gosu::Color::GREEN,
					:text => "HP", :font => @font, :color => Gosu::Color::RED,
					:text_align => :center, :vertical_align => :top
		heath_label_offset_x = 10
		width = 100
		x = (@window.width/2) + heath_label_offset_x
		y = @window.height - 35
		@hp_numerical_display = Widget::Label.new window, x,y,
								:width => width, :height => @font.height,
								#~ :background_color => Gosu::Color::GREEN,
								:text => "", :font => @font, :color => Gosu::Color::RED,
								:text_align => :center, :vertical_align => :top
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
		x = (@window.width/2 - @health_gear.width/2)+side_gear_offset_x
		y = @window.height - side_gear_offset_y
		z = 100
		@health_gear.draw x, y, z
		# Health label
		#~ heath_label_offset_x = 120
		#~ x = (@window.width/2 - @health_gear.width/2)+heath_label_offset_x
		#~ y = @window.height - 60 -20
		#~ z = 100
		#~ @font.old_draw "HP", x,y,z, 1,1, Gosu::Color::RED
		@hp_label.draw
		# Health level (text)
		@hp_numerical_display.draw
	end
end

