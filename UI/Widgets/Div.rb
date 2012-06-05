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
		
		attr_reader :padding
		
		def initialize(window, x, y, options={})
			options = 	{
				:z_index => 0,
				:relative => window,
				:align => :left,
				
				:position => :static, # static, dynamic, relative
				#~ :anchor => :top_left # broad descriptor of where the object is anchored
				#~ :anchor_offset => nil # CP::Vec2 to offset from the anchor
				
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
			
			# ===== Z Index
			if options[:relative] != window
				options[:z_index] += options[:relative].pz + 1
			end
			
			super(window, options[:z_index])
			
			# ===== Calculate geometry and position
			#~ x = calculate_geometry_and_position window, options, :left, :right, :width, :x
			#~ y = calculate_geometry_and_position window, options, :top, :bottom, :height, :y
			
			
			
			if options[:relative] != window
				x += options[:relative].render_x
				y += options[:relative].render_y
			end
			
			@width =		case options[:width_units]
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
					
			@height =	case options[:height_units]
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
			
			#~ width =	dimension options[:relative], options[:width_units], options[:width]
			#~ height = dimension options[:relative], options[:height_units], options[:height]
			
			
			#~ mass = 100
			#~ moment = 100
			#~ init_physics	[x,y], width, height, mass, moment, :div
			@body = CP::Body.new_static()
			@shape = Physics::Shape::Rect.new self, @body, @width, @height
			@shape.collision_type = :div
			@body.p = CP::Vec2.new(x,y)
			
			#~ init_physics	[x,y], width, height, :static, :static, :div
			
			init_background	options[:background_color]
			
			
			
			# Currently alignment is not taken into account
			@align = options[:align]
			
			# This hash should be frozen if information can not be edited at runtime
			@padding = {:top => options[:padding_top],
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
		
		#~ private
		
		def render_x
			self.px+@padding[:left]
		end
		
		def render_y
			self.py+@padding[:top]
		end
		
		private
		
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
