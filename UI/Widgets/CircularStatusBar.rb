module Widget
	class CircularStatusBar < Div
		def initialize(window, x,y, options={})
			options = {
				:stroke_width => 3,	# Width of the line
				:slices => 30, # Number of subdivisions around the z axis.
				:loops => 1, # Number of concentric rings about the origin.
				
				:start_angle => 0,
				
				:color => Gosu::Color.new(0xFFFFFFFF), # Color is argb
				
				:z_index => 0,
				:relative => window,
				:align => :left,
				
				:radius => 10 # Radius of the circular bar, in px
				:width_units => :px, # Should not change
				:height_units => :px, # Should not change
				
				:percent => nil,
				:angle => nil
			}.merge! options
			options[:height] = options[:width] = options[:radius]
			
			super(window, x,y, options)
			
			@radius = options[:radius]
			@stroke_width = options[:stroke_width]
			@slices = options[:slices]
			@loops = options[:loops]
			
			# The angle from which the status bar arc will start
			# Given Gosu's coordinate system, 0deg is down, and positive rotation is CCW
			@start_angle = options[:start_angle]
			# Store angle to arc through in degrees, as needed by gluPartialDisk
			@angle = options[:angle]
			# Cache percent represented on the bar
			@percent = 0
			
			@color = options[:color]
		end
		
		def update(percent)
			# Update the displayed angle to match the given percent
			# Percents should be provided as a double (ex, 1.0, 0.20, etc)
			if percent != @percent
				@percent = percent
				@angle = 360 * percent
			end
		end
		
		def draw(x,y)
			# Draw the ring centered on the position specified by the central coord
			# Coordinates are given in window coordinates, in units of px
			
			@window.gl @pz do
				#~ glPolygonMode(GL_FRONT, GL_FILL) # Probably doesn't affect quadrics
				
				glPushMatrix()
					#~ glLoadIdentity()
					
					glColor3f(@color.red, @color.green, @color.blue)
					glTranslatef(x, y, 0)
					# Given Gosu's coordinate system, 0deg is down, pos rotation is CCW
					gluPartialDisk(@quadric, @radius-@stroke_width, @radius, 
									@slices, @loops, @start_angle, @angle)
				glPopMatrix()
			end
		end
	end
end
