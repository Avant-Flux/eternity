module Widget
	class CircularStatusBar < Div
		# Currently offsetting by radius so the circular bar is drawn centered on 
		# coordinates.  This has implications on the render context provided by
		# this widget.
		
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
				
				:radius => 10, # Radius of the circular bar, in px
				:width_units => :px, # Should not change
				:height_units => :px, # Should not change
				
				:bar_units => :percent, # :percent, :angle
				:bar_initial_value => 1.0
			}.merge! options
			options[:height] = options[:width] = options[:radius]
			
			super(window, x,y, options)
			
			@units  = options[:bar_units]
			
			@radius = options[:radius]
			@stroke_width = options[:stroke_width]
			@slices = options[:slices]
			@loops = options[:loops]
			
			# The angle from which the status bar arc will start
			# Given Gosu's coordinate system, 0deg is down, and positive rotation is CCW
			@start_angle = options[:start_angle]
			
			# Store angle to arc through in degrees, as needed by gluPartialDisk
			# Cache percent represented on the bar as well
			if options[:bar_units] == :percent
				@percent = options[:bar_initial_value]
				@angle = 360*@percent
			else
				@angle = options[:bar_initial_value]
				@percent = @angle/360.0 / 100
			end
			
			@color = options[:color]
		end
		
		def update(bar_value)
			# Update the displayed angle to match the given percent
			# Percents should be provided as a double (ex, 1.0, 0.20, etc)
			# NOTE: May want to remove the equality check, as it will not work for doubles
			if @units == :percent
				if bar_value != @percent
					@percent = bar_value
					@angle = 360 * @percent
				end
			else # :degrees
				if bar_value != @angle
					@angle = bar_value
					@percent = @angle/360.0 / 100
				end
			end
		end
		
		def draw
			# Draw the ring centered on the position specified by the central coord
			# Coordinates are given in window coordinates, in units of px
			
			@window.gl @pz do
				#~ glPolygonMode(GL_FRONT, GL_FILL) # Probably doesn't affect quadrics
				
				glPushMatrix()
					#~ glLoadIdentity()
					
					glColor3f(@color.red, @color.green, @color.blue)
					glTranslatef(px+@radius, py+@radius, 0)
					# Given Gosu's coordinate system, 0deg is down, pos rotation is CCW
					gluPartialDisk(@quadric, @radius-@stroke_width, @radius, 
									@slices, @loops, @start_angle, @angle)
				glPopMatrix()
			end
		end
	end
end
