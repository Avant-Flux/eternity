class HP_Indicator < Widget::Div
	def initialize(window, x,y, player, options={})
		@player = player
		
		@font = Gosu::Font.new window, "Helvetica Bold", 25
		
		@health_gear = Gosu::Image.new window,
						"./Development/Interface/new_interface/health_gauge.png", false
		@health_fill = Gosu::Image.new window,
						"./Development/Interface/new_interface/health_fill.png", false
		
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
									
									:top => :auto,			:bottom => :auto,
									:left => :auto,		:right => :auto,
									
									:text => "", :font => @font,
									#~ :color => Gosu::Color.rgb(86,86,86),
									:color => Gosu::Color::WHITE,
									:text_align => :center, :vertical_align => :top,
									
									:background_color => Gosu::Color::NONE
		
		@mask = lambda do
			# Must be all OpenGL code
			glColor3f(1.0,1.0,1.0)
			
			glPushMatrix()
				glTranslatef(self.render_x+10, self.render_y+self.height-10, 0)
				
				hp_percent = @player.hp.to_f/@player.max_hp
				
				height = -self.height+21
				glBegin(GL_QUADS)
					glVertex2i(0, 0)
					glVertex2i(0, height*hp_percent)
					glVertex2i(self.width, height*hp_percent)
					glVertex2i(self.width, 0)
				glEnd()
			glPopMatrix()
		end
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
		@window.stencil @mask, @pz do
			glPushMatrix()
				glTranslatef(self.render_x+10, self.render_y+10, 0)
				
				glEnable(GL_ALPHA_TEST)
				glAlphaFunc(GL_GREATER, 0)
				
				glEnable(GL_TEXTURE_2D)
				glBindTexture(GL_TEXTURE_2D, @health_fill.gl_tex_info.tex_name)
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
				
				glColor3f(1.0,1.0,1.0)
				
				#~ # Backface culling used to make sure polygon winding is correct
				#~ glEnable(GL_CULL_FACE)
				#~ glCullFace(GL_BACK)
				
				glBegin(GL_QUADS)
					glTexCoord2d(@health_fill.gl_tex_info.left, @health_fill.gl_tex_info.top); 
						glVertex2i(0, 0)
					glTexCoord2d(@health_fill.gl_tex_info.left, @health_fill.gl_tex_info.bottom);
						glVertex2i(0, @health_fill.height)
					glTexCoord2d(@health_fill.gl_tex_info.right, @health_fill.gl_tex_info.bottom);
						glVertex2i(@health_fill.width, @health_fill.height)
					glTexCoord2d(@health_fill.gl_tex_info.right, @health_fill.gl_tex_info.top); 
						glVertex2i(@health_fill.width, 0)
				glEnd()
			glPopMatrix()
		end
		
		#~ @window.gl do
			#~ @mask.call
		#~ end
		
		@health_gear.draw self.render_x, self.render_y, @pz
		
		@hp_label.draw
		# Health level (text)
		@hp_numerical_display.draw
	end
end

