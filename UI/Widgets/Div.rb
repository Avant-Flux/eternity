#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# A roped-off zone where content can be rendered
	# Other widgets, as well as Gosu::Image instances, should
	# be able to exist within this context.
	class Div < UI_Object
		#~ include Physics::TwoD_Support
		#~ include Physics::TwoD_Support::Rect
		
		include Background::Colored
		
		attr_reader :width, :height # TODO: Delegate width and height to physics object 
		attr_reader :padding
		
		DEFAULTS = {
			:z_index => 0,
			:align => :left,
			
			:position => :static, # static, dynamic
			#~ :anchor => :top_left # broad descriptor of where the object is anchored
			#~ :anchor_offset => nil # CP::Vec2 to offset from the anchor
			
			:width => 1, # Number or :auto
			:width_units => :px, # px, em, 
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
		}
		
		def initialize(window, x, y, options={})
			# TODO: Change the :relative hash parameter into a real argument
			options[:relative] ||= window
			options = DEFAULTS.merge options
			
			# TODO:	Throw error unless both this widget and the widget it is relative to are
			# 		either both :static, or both :dynamic in :position
			
			
			# ===== Z Index
			if options[:relative] != window
				options[:z_index] += options[:relative].pz + 1
			end
			
			super(window, options[:z_index])
			
			# ===== Calculate geometry and position
			#~ x = calculate_geometry_and_position window, options, :left, :right, :width, :x
			#~ y = calculate_geometry_and_position window, options, :top, :bottom, :height, :y
			
			
			# Offset in ems set relative to containers em width
			# Width and Height set relative to current object em width
			
			
			# There are no inline elements in this style, as there is no natural flow.
			# 
			# All positioning should be done relative to the coordinate system established by
			# the element specified by options[:relative].  Transformation into "global" 
			# coordinates should be done at the very end.
			# 	Only chain once, as each element stores global coordinates, NOT local ones
			
			if options[:position] == :static
				# Units: Px
				if options[:width] == :auto
					# Stretch to fit container
					# Remember to take :top, :bottom, :left, :right into account
					width	=	relative.width - options[:left] - options[:right]
					x += options[:left]
				else
					# Sized element
					
					# Calculate size in pixels
					width = case options[:width_units]
						when :percent
							# Doesn't matter if the object the percent is relative to is measured in
							# meters or pixels.  If it's world relative, the input with be meters,
							# and the output will be meters.  Similarly for screen, but with pixels.
							options[:width] * relative.width
						when :px
							options[:width]
						when :meters
							options[:width].to_px
						when :em
							options[:width] * options[:relative].font.text_width('m')
					end
					
					
					# Calculate offset from sides
					if options[:left] == :auto && options[:right] == :auto
						# Center on x-axis
						# TODO: Remember to convert relative.width to pixels
						#~ x = relative.width / 2 - width / 2
						x = (relative.width - width) / 2
					else
						# Set relative to positioning options
						# Check if left or right is numerical
						# Left has priority (lower number of x-axis)
						# Align edge to corresponding edge of container, with offset
						if options[:left] != :auto
							x = 0 + 0 + options[:left]
						elsif options[:right] != :auto
							x = relative.width - width - options[:right]
						end
					end
				end
				
				if options[:height] == :auto
					# Stretch to fit
					# Stretch to fit container
					# Remember to take :top, :bottom, :left, :right into account
					height	=	relative.height - options[:top] - options[:bottom]
					y += options[:top]
				else
					# Sized
					
					
					# Calculate size in pixels
					height = case options[:height_units]
						when :percent
							# Doesn't matter if the object the percent is relative to is measured in
							# meters or pixels.  If it's world relative, the input with be meters,
							# and the output will be meters.  Similarly for screen, but with pixels.
							options[:height] * relative.width
						when :px
							options[:height]
						when :meters
							options[:height].to_px
						when :em
							options[:height] * options[:relative].font.text_width('m')
					end
					
					
					if options[:top] == :auto && options[:bottom] == :auto
						# Center on y-axis
						#~ y = relative.height / 2 - height / 2
						y = (relative.height - height) / 2
					else
						# Set relative to positioning options
						# Check if top or bottom is numerical
						# Top has priority (lower number of y-axis)
						# Align edge to corresponding edge of container, with offset
						if options[:top] != :auto
							y = 0 + 0 + options[:top]
						elsif options[:bottom] != :auto
							y = relative.height - height - options[:bottom]
						end
					end
				end
			elsif options[:position] == :dynamic
				# Units: Meters
				
				# For :auto dimension, stretch to fit, if there is a parent
				# 	If no parent is declared (element is relative to a gameobject)
				# 	shrinkwrap the element
			end
			
			
			
			
			
			
			
			
			
			
			
			
			
			if options[:relative] != window
				x += options[:relative].render_x
				y += options[:relative].render_y
			end
			
			set_width options
			set_height options
			
			#~ width =	dimension options[:relative], options[:width_units], options[:width]
			#~ height = dimension options[:relative], options[:height_units], options[:height]
			
			init_physics x,y
			
			
			init_background	options[:background_color]
			
			
			
			# Currently alignment is not taken into account
			@align = options[:align]
			
			# This hash should be frozen if information can not be edited at runtime
			@padding = {
				:top => options[:padding_top],
				:bottom => options[:padding_bottom],
				:left => options[:padding_left],
				:right => options[:padding_right]
			}
		end
		
		def update
			
		end
		
		def draw
			draw_background @pz
		end
		
		def width
			@shape.width
		end
		
		def height
			@shape.height
		end
		
		def render_x
			@body.p.x+@padding[:left]
		end
		
		def render_y
			@body.p.y+@padding[:top]
		end
		
		private
		
		def init_physics(x,y)
			#~ mass = 100
			#~ moment = 100
			#~ init_physics	[x,y], width, height, mass, moment, :div
			@body = CP::Body.new_static()
			@shape = Physics::Shape::Rect.new self, @body, @width, @height
			@shape.collision_type = :div
			@body.p = CP::Vec2.new(x,y)
			
			#~ init_physics	[x,y], width, height, :static, :static, :div
		end
		
		def set_width(options)
			@width = case options[:width_units]
				when :px
					options[:width]
				when :em
					# Not defined for the window
					options[:width] * options[:relative].font.text_width('m')
				when :percent
					# Specify :meters so that the measurement is not scaled
					output =	if options[:relative].is_a? Gosu::Window
							options[:relative].send :width
						else
							options[:relative].send :width, :meters
						end
					
					if options[:relative].respond_to? :padding
						output -= options[:relative].padding[:left]
						output -= options[:relative].padding[:right]
					end
					
					(output * options[:width]/100.0).to_i
			end
		end
		
		def set_height(options)
			@height = case options[:height_units]
				when :px
					options[:height]
				when :em
					# Not defined for the window
					options[:height] * options[:relative].font.text_width('m')
				when :percent
					# Specify :meters so that the measurement is not scaled
					output =	if options[:relative].is_a? Gosu::Window
							options[:relative].send :height
						else
							options[:relative].send :height, :meters
						end
						
					if options[:relative].respond_to? :padding
						output -= options[:relative].padding[:top]
						output -= options[:relative].padding[:bottom]
					end
					
					(output * options[:height]/100.0).to_i
			end
		end
		
		def calculate_geometry_and_position(window, options, side1, side2, dimension, axis)
			if options[:position] == :static
				if options[side1] == :auto && options[side2] == :auto
					# Expand to fill container in both pos and neg directions of axis
					# Expand to remaining space in the parent container
					# Not the same as setting width to 100% of container
					# Ideally, you want to examine how much of the parent is already occupied
					# 	by siblings of the current element
					
				elsif options[side1] != :auto && options[side2] == :auto
					# Side closer to origin has defined position, far side expands as much as possible
					# Not the same as setting width to 100% of container
					
				elsif options[side1] != :auto && options[side2] == :auto
					# Close side expands as much as possible, far side 
					# Not the same as setting width to 100% of container
					
				else
					# Expand to both sides to the maximum extent possible
					# Not the same as setting width to 100% of container
					
				end
			else # options[:position] == :relative
				
			end
			
			
			
			#~ if options[side1] != :auto && options[side2] != :auto
				#~ options[dimension] = options[:relative].send(dimension) - options[side1] - options[side2]
				#~ 
				#~ if options[:relative] == window
					#~ return 0
				#~ else
					#~ return options[:relative].send("render_#{axis}")
				#~ end
			#~ else
				#~ if options[side1] != :auto
					#~ # Align to top and set height explicitly
					#~ # If height is not set, then expand to remaning height of container
					#~ if options[:relative] == window
						#~ return options[side1]
					#~ else
						#~ return options[:relative].send("render_#{axis}") + options[side1]
					#~ end
				#~ end
				#~ 
				#~ if options[side2] != :auto
					#~ # Align to bottom and set height explicitly
					#~ # If height is not set, then expand to remaning height of container
					#~ if options[:relative] == window
						#~ return options[side2]
					#~ else
						#~ return options[:relative].send("render_#{axis}") - options[side2]
					#~ end
				#~ end
			#~ end
		end
		
		def relative_size(relative, dimension)
			if relative.is_a? Gosu::Window
				relative.send dimension
			else
				relative.send dimension, :meters
			end
		end
		
		# Convert the value in the specified dimension to pixels
		def dimension(relative, padding, units, value)
			return case units
				when :px
					value
				when :em
					# Not defined for the window
					value * relative.font.text_width('m')
				when :percent
					# Specify :meters so that the measurement is not scaled
					x =	if relative.is_a? Gosu::Window
							relative.send :width
						else
							relative.send :width, :meters
						end
					x -= padding[:left]
					x -= padding[:right]
					
					(x * value/100.0).to_i
			end
		end
	end
end
