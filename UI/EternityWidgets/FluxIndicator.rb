class FluxIndicator < Widget::Div
	def initialize(window, x,y, player, options={})
		@player = player
		
		@flux_gear = Gosu::Image.new window,
						"#{Widget::IMAGE_DIR}/flux_gauge.png", false
		@flux_fill = Gosu::Image.new window,
						"#{Widget::IMAGE_DIR}/flux_fill.png", false
		options[:width] = @flux_gear.width
		options[:height] = @flux_gear.height
		
		super(window, x,y, options)
		
		@font = Gosu::Font.new @window, "Helvetica Bold", 25
		
		
		@mask = lambda {
			# Must be all OpenGL code
			glColor3f(1.0,1.0,1.0)
			glEnable(GL_ALPHA_TEST)
			glAlphaFunc(GL_GREATER, 0)
			glPushMatrix()
				glTranslatef(self.render_x, self.render_y+self.height-20, 0)
				
				#~ percent = @player.flux
				percent = 1.2
				
				bubble_percent, overflow_percent = bubble_fill percent
				
				
				bubble_height = -85
				overflow_height = -58
				
				height = bubble_height*bubble_percent + overflow_height*overflow_percent
				
				glBegin(GL_QUADS)
					glVertex2i(0, 0)
					glVertex2i(0, height)
					glVertex2i(self.width, height)
					glVertex2i(self.width, 0)
				glEnd()
			glPopMatrix()
		}
	end
	
	def update
		super()
	end
	
	def draw
		super()
		
		# Flux
		# White fill
		@window.stencil @mask, @pz do
			glPushMatrix()
				glTranslatef(self.render_x+17, self.render_y-7, 0)
				
				glEnable(GL_ALPHA_TEST)
				glAlphaFunc(GL_GREATER, 0)
				
				glEnable(GL_TEXTURE_2D)
				glBindTexture(GL_TEXTURE_2D, @flux_fill.gl_tex_info.tex_name)
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
				
				glColor3f(1.0,1.0,1.0)
				
				#~ # Backface culling used to make sure polygon winding is correct
				#~ glEnable(GL_CULL_FACE)
				#~ glCullFace(GL_BACK)
				
				glBegin(GL_QUADS)
					glTexCoord2d(@flux_fill.gl_tex_info.left, @flux_fill.gl_tex_info.top)
						glVertex2i(0, 0)
					glTexCoord2d(@flux_fill.gl_tex_info.left, @flux_fill.gl_tex_info.bottom)
						glVertex2i(0, @flux_fill.height)
					glTexCoord2d(@flux_fill.gl_tex_info.right, @flux_fill.gl_tex_info.bottom)
						glVertex2i(@flux_fill.width, @flux_fill.height)
					glTexCoord2d(@flux_fill.gl_tex_info.right, @flux_fill.gl_tex_info.top)
						glVertex2i(@flux_fill.width, 0)
				glEnd()
			glPopMatrix()
		end
		
		#~ @window.gl do
			#~ @mask.call
		#~ end
		
		@flux_gear.draw	self.render_x, self.render_y, @pz#, 1,1, Gosu::Color.new(0x55ffffff)
	end
	
	private
	
	def bubble_fill(percent)
		# Double return: bubble percent, overflow percent
		bubble_percent = overflow_percent = 0.0
		
		
		
		
		if percent > 1.0
			bubble_percent = 1.0			# Bubble is full and gauge is overflowing
			overflow_percent = percent % 1	# Only the fractional portion
			
			# Convert overflow percent to a percentage of the image to be displayed
			overflow_percent /= 0.20		# TODO: Define max flux constant
		else
			overflow_percent = 0.0
			bubble_percent = percent
		end
		
		return bubble_percent, overflow_percent
	end
end

