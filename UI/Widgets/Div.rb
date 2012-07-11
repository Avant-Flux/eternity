#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# A roped-off zone where content can be rendered
	# Other widgets, as well as Gosu::Image instances, should
	# be able to exist within this context.
	# TODO: Style should cascade, copying non-overridden style options from parent
	class Div < UI_Object
		include Background::Colored
		
		attr_reader :padding
		
		DEFAULTS = {
			:z_index => 0,
			:align => :left,
			
			:position => :static, # static, dynamic
			#~ :anchor => :top_left # broad descriptor of where the object is anchored
			#~ :anchor_offset => nil # CP::Vec2 to offset from the anchor
			
			:width => :auto, # Number or :auto
			:width_units => :px, # px, em, 
			:height => :auto,
			:height_units => :px,
			
			:background_color => Gosu::Color::GREEN, # obnoxious color by default
			
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
			
			@relative = options[:relative]
			# TODO:	Throw error unless both this widget and the widget it is relative to are
			# 		either both :static, or both :dynamic in :position
			
			# ===== Z Index
			if @relative != window
				options[:z_index] += @relative.pz
			end
			
			super(window, options[:z_index])
			
			# ===== Calculate geometry and position
			# Offset in ems set relative to containers em width
			# Width and Height set relative to current object em width
			
			# All positioning should be done relative to the coordinate system established by
			# the element specified by options[:relative].  Transformation into "global" 
			# coordinates should be done at the very end.
			# 	Only chain once, as each element stores global coordinates, NOT local ones
			dimensions = {}
			position = []
			
			if options[:position] == :static
				# Units: Px
				axis = Axis.new
				
				[:width, :height].each_with_index do |d, i|
					if options[d] == :auto
						# Stretch to fit container
						# Remember to take :top, :bottom, :left, :right into account
						# TODO: Take padding into account as well
						dimensions[d] =	static_stretched_dimension d, axis, options
						
						position[i] = options[axis.dimension(d).low]
					else
						units = options["#{d}_units".to_sym]
						dimensions[d] = static_sized_dimension d, units, options
						position[i] = static_sized_position d, axis, dimensions, options
					end
				end
			elsif options[:position] == :dynamic
				# Units: Meters
				
				# For :auto dimension, stretch to fit, if there is a parent
				# 	If no parent is declared (element is relative to a gameobject)
				# 	shrinkwrap the element
				
				# NOTE:	Try to use the same dimension code from :static,
				# 		but with new positioning code.  Widgets will still be billboarded
				# 		viewport-relative in their size.  This means that objects further
				# 		away will not be rendered any smaller.  This is in concert with
				# 		the trimetric projection, which does not have perspective deformation.
			end
			
			
			# Move widget into position relative to it's parent
			# TODO: Consider padding
			if @relative != window
				x += @relative.render_x
				y += @relative.render_y
			end
			
			margins = margin options
			x += margins[0]
			y += margins[1]
			
			# Move object into global position
			position[0] += x
			position[1] += y
			
			# Set-up Chipmunk object to store physical properties of this widget
			init_physics dimensions[:width], dimensions[:height], *position, :div
			
			
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
		
		def init_physics(width,height, x,y, collision_type)
			#~ mass = 100
			#~ moment = 100
			#~ init_physics	[x,y], width, height, mass, moment, :div
			@body = CP::Body.new_static()
			@shape = Physics::Shape::Rect.new self, @body, width, height
			@shape.collision_type = collision_type
			@body.p = CP::Vec2.new(x,y)
			
			#~ init_physics	[x,y], width, height, :static, :static, :div
		end
		
		def margin(style)
			x_offset = 0
			y_offset = 0
			
			# Convert units to px
			# The margin offset will always be relative to another widget
			# 	If the parent is a window
			# 		Offset from the edge as normal
			# 	If the parent is not a widget, and the current widget is dynamic
			# 		The widget is placed world-relative
			# 		However, the widget is offset as if it was being placed relative to an
			# 		 invisible widget.
			# Position relative to the inner box of the parent
			# 	ie, don't forget about the padding
			
			
			# Convert measurements to px
			[:margin_top, :margin_right, :margin_bottom, :margin_left].each_with_index do |margin_type, i|
				if margin_type
					case style["#{margin_type}_units".to_sym]
						when :percent
							if i % 2 == 0
								style[margin_type] *=  @relative.height/100.0
							else
								style[margin_type] *=  @relative.width/100.0
							end
						when :em
							style[margin_type] *= @relative.font.text_width('m')
					end
				end
			end
			
			if style[:margin_left]
				x_offset += style[:margin_left]
			end
			
			if style[:margin_right]
				x_offset -= style[:margin_right]
			end
			
			if style[:margin_top]
				y_offset += style[:margin_top]
			end
			
			if style[:margin_bottom]
				y_offset -= style[:margin_bottom]
			end
			
			
			return x_offset, y_offset
		end
		
		def static_stretched_dimension(d, axis, style)
			@relative.send(d) - style[axis.dimension(d).low] - style[axis.dimension(d).high]
		end
		
		def static_sized_dimension(dimension, units, style)
			# Screen-relative, so all units eventually convert to px
			case units
				when :percent
					# Doesn't matter if the object the percent is relative to is measured in
					# meters or pixels.  If it's world relative, the input with be meters,
					# and the output will be meters.  Similarly for screen, but with pixels.
					return style[dimension]/100.0 * @relative.send(dimension)
				when :px
					return style[dimension]
				when :meters
					return style[dimension].to_px
				when :em
					return style[dimension] * @relative.font.text_width('m')
			end
		end
		
		def static_sized_position(d, axis, dimensions, style)
			# Screen relative, so all units eventually convert to px
			# Calculate offset from boundaries
			if style[axis.dimension(d).low] == :auto && 
			style[axis.dimension(d).high] == :auto
				# Center on axis
				# TODO: Remember to convert relative dimension to pixels
				#~ x = relative.width / 2 - width / 2
				#~ x = (relative.width - width) / 2
				return (@relative.send(d) - dimensions[d]) / 2
			else
				# Set relative to positioning options
				# Check if left or right is numerical
				# Priority to low end of axis
				# Align edge to corresponding edge of container, with offset
				# TODO: Consider padding
				if style[axis.dimension(d).low] != :auto
					return 0 + 0 + style[axis.dimension(d).low]
				elsif style[axis.dimension(d).high] != :auto
					return @relative.send(d) - dimensions[d] - style[axis.dimension(d).high]
				end
			end
		end
		
		class Axis
			def initialize
				@hash = {
					:x => Foo.new(:left, :right),
					:y => Foo.new(:top, :bottom),
				}
				@hash.freeze # No further changes
			end
			
			def [](arg)
				@hash[arg]
			end
			
			def dimension(d)
				case d
					when :width
						@hash[:x]
					when :height
						@hash[:y]
				end
			end
			
			private
			
			Foo = Struct.new(:low, :high)
		end
	end
end
