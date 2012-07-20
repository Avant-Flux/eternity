class MP_Indicator < Widget::Div
	def initialize(window, x,y, player, options={})
		@player = player
		
		@font = Gosu::Font.new window, "Helvetica Bold", 25
				
		# Background
		@mana_gear = Gosu::Image.new window,
						"./Development/Interface/new_interface/mana_gauge.png", false
		@mana_fill = Gosu::Image.new window,
						"./Development/Interface/new_interface/mana_fill.png", false
		
		options[:height] = @mana_gear.height
		options[:width] = @mana_gear.width
		super(window, x,y, options)
		
		@mp_label = Widget::Label.new window, 0,0,
						:relative => self,
						:width => 50, :height => @font.height,
						
						:margin_right => 100,	:margin_right_units => :percent,
						:margin_top => 10,		:margin_top_units => :px,
						
						:top => :auto,			:bottom => :auto,
						:left => :auto,			:right => 0,
						
						:text => "MP", :font => @font, :color => Gosu::Color::BLUE,
						:text_align => :center, :vertical_align => :bottom,
						
						:background_color => Gosu::Color::YELLOW
		
		@mp_numerical_display = Widget::Label.new window, 0,0,
									:relative => self,
									:width => 100, :height => @font.height,
									
									:top => :auto,			:bottom => :auto,
									:left => :auto,		:right => :auto,
									
									:text => "", :font => @font,
									#~ :color => Gosu::Color.rgb(86,86,86),
									:color => Gosu::Color::WHITE,
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
		mask = lambda do
			# Must be all OpenGL code
			glPushMatrix()
				glColor3f(1.0,1.0,1.0)
				
				glTranslatef(self.render_x+10, self.render_y+self.height-12, 0)
				
				mp_percent = @player.mp.to_f/@player.max_mp
				
				height = -self.height+23
				glBegin(GL_QUADS)
					glVertex2i(0, 0)
					glVertex2i(0, height*mp_percent)
					glVertex2i(self.width, height*mp_percent)
					glVertex2i(self.width, 0)
				glEnd()
			glPopMatrix()
		end
		
		@window.stencil mask, @pz do
			glPushMatrix()
				glTranslatef(self.render_x+10, self.render_y+10, 0)
				
				glEnable(GL_ALPHA_TEST)
				glAlphaFunc(GL_GREATER, 0)
				
				glEnable(GL_TEXTURE_2D)
				glBindTexture(GL_TEXTURE_2D, @mana_fill.gl_tex_info.tex_name)
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
				
				glColor3f(1.0,1.0,1.0)
				
				#~ # Backface culling used to make sure polygon winding is correct
				#~ glEnable(GL_CULL_FACE)
				#~ glCullFace(GL_BACK)
				
				glBegin(GL_QUADS)
					glTexCoord2d(@mana_fill.gl_tex_info.left, @mana_fill.gl_tex_info.top); 
						glVertex2i(0, 0)
					glTexCoord2d(@mana_fill.gl_tex_info.left, @mana_fill.gl_tex_info.bottom);
						glVertex2i(0, @mana_fill.height)
					glTexCoord2d(@mana_fill.gl_tex_info.right, @mana_fill.gl_tex_info.bottom);
						glVertex2i(@mana_fill.width, @mana_fill.height)
					glTexCoord2d(@mana_fill.gl_tex_info.right, @mana_fill.gl_tex_info.top); 
						glVertex2i(@mana_fill.width, 0)
				glEnd()
			glPopMatrix()
		end
		
		#~ @window.gl do
			#~ mask.call
		#~ end
		
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

