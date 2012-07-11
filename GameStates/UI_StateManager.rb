
class UI_StateManager
	def initialize(window, player, state_manager)
		@window = window
		@player = player
		@state_manager = state_manager
		
		@space = CP::Space.new
		
		@map = Map.new(@window, @space, @player, @state_manager)
		#~ @stack = Array.new5
		@stack = [
			UI_State.new(@window, @space, @player),
		]
	end
	
	def update
		#~ @space.step 1/60.0
		
		@stack.each do |interface|
			interface.update
		end
	end
	
	def draw
		#~ stencil_buffer_test
		
		@stack.each do |interface|
			interface.draw
			
			@window.flush
		end
	end
	
	def current
		return @stack.last
	end
	
	# Close all states, up to and including a state of the given class
	# If no parameter, then just pop one state
	# WARNING: Can completely deplete the stack, which will result in no UI
	def pop(klass=nil)
		if klass
			begin
				state = @stack.pop
			end until(state.is_a? klass)
		else
			@stack.pop
		end
	end
	
	def open_map
		@stack << @map 
	end
	
	private
	
	def stencil_buffer_test
		z_index = 1
		mask = lambda do
			
			#~ glColor3f(0,255,0)
			
			glPushMatrix()
				glTranslatef(100,100,0)
				#~ r = 1000
				#~ glTranslatef(100,100,0)
				#~ gluPartialDisk(gluNewQuadric(), r,r, 30, 1,	0, 360)
				
				width = 200
				height = 200
				glBegin(GL_TRIANGLES)
					glVertex2f(0,0)
					glVertex2f(width,0)
					glVertex2f(width,height)
				glEnd()
			glPopMatrix()
		end
		
		@window.stencil mask, z_index do
			glColor3f(255,0,0)
			
			glPushMatrix()
				glTranslatef(100,100,0)
				
				width = 600
				height = 600
				glBegin(GL_QUADS)
					glVertex2f(0,0)
					glVertex2f(width,0)
					glVertex2f(width,height)
					glVertex2f(0,height)
				glEnd()
			glPopMatrix()
		end
	end
end
