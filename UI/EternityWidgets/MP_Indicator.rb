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
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
				
		# Background
		#~ @mana_gear = Gosu::Image.new window, 
					#~ "./Development/Interface/interface720/mpgear.png", false
		
		@mana_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/mpgear.png", false
		
		heath_label_offset_x = 80
		width = 50
		x = (@window.width/2 - width)-heath_label_offset_x
		y = @window.height - 60 - 20
		@mp_label = Widget::Label.new window, x,y,
					:width => width, :height => @font.height,
					#~ :background_color => Gosu::Color::GREEN,
					:text => "MP", :font => @font, :color => Gosu::Color::RED,
					:text_align => :center, :vertical_align => :top
		
		heath_label_offset_x = 10
		width = 100
		x = (@window.width/2 - width) - heath_label_offset_x
		y = @window.height - 35
		z = 100
		@mp_numerical_display = Widget::Label.new window, x,y,
								:width => width, :height => @font.height,
								#~ :background_color => Gosu::Color::FUCHSIA,
								:text => "", :font => @font, :color => Gosu::Color::RED,
								:text_align => :center, :vertical_align => :top
	end
	
	def update(mp, max_mp)
		super()
		@mp_numerical_display.text = "#{mp} | #{max_mp}"
	end
	
	def draw
		super()
		scale_side_gears = 0.25
		#~ side_gear_offset_x = 55
		side_gear_offset_x = 48
		side_gear_offset_y = 45+40+20
		
		
		# Mana
		# Mana Orb
		# Blue fill
		x = (@window.width/2 - @mana_gear.width/2)-side_gear_offset_x
		y = @window.height - side_gear_offset_y
		z = 100
		@mana_gear.draw x, y, z 
		# Mana label
		#~ heath_label_offset_x = 90
		#~ x = (@window.width/2 - @mana_gear.width/2)-heath_label_offset_x
		#~ y = @window.height - 60 - 20
		#~ z = 100
		#~ @font.old_draw "MP", x,y,z, 1,1, Gosu::Color::RED
		@mp_label.draw
		# Mana level (text)
		@mp_numerical_display.draw
		
		#~ @window.gl z do
			#~ glBegin(GL_LINES)
				#~ glVertex2i(30,30)
				#~ glVertex2i(200,30)
			#~ glEnd()
		#~ end
	end
end

