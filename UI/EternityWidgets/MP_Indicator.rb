class MP_Indicator < Widget::Div
	def initialize(window, x,y, options={})
		@font = Gosu::Font.new window, "Helvetica Bold", 25
				
		# Background
		@mana_gear = Gosu::Image.new window,
						"./Development/Interface/interface720/mpgear.png", false
		
		options[:height] = @mana_gear.height
		options[:width] = @mana_gear.width
		super(window, x,y, options)
		
		heath_label_offset_x = 80
		width = 50
		x = (@window.width/2 - width)-heath_label_offset_x
		y = @window.height - 60 - 20
		@mp_label = Widget::Label.new window, 0,0,
						:relative => self,
						:width => width, :height => @font.height,
						
						:margin_right => 100,	:margin_right_units => :percent,
						:margin_top => 10,		:margin_top_units => :px,
						
						:top => :auto,			:bottom => :auto,
						:left => :auto,			:right => 0,
						
						:text => "MP", :font => @font, :color => Gosu::Color::BLUE,
						:text_align => :center, :vertical_align => :bottom,
						
						:background_color => Gosu::Color::YELLOW
		
		heath_label_offset_x = 10
		width = 100
		x = (@window.width/2 - width) - heath_label_offset_x
		y = @window.height - 35
		@mp_numerical_display = Widget::Label.new window, 0,0,
									:relative => self,
									:width => width, :height => @font.height,
									
									:margin_top => 100, :margin_top_units => :percent,
									
									:top => 0,			:bottom => :auto,
									:left => :auto,		:right => -5,
									
									:text => "", :font => @font, :color => Gosu::Color::BLUE,
									:text_align => :center, :vertical_align => :top,
									
									:background_color => Gosu::Color::NONE
	end
	
	def update(mp, max_mp)
		super()
		@mp_numerical_display.text = "#{mp} | #{max_mp}"
	end
	
	def draw
		super()
		# Mana
		# Mana Orb
		# Blue fill
		@mana_gear.draw self.render_x, self.render_y, @pz 
		
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

