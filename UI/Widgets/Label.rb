#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

module Widget
	# Similar to button, but not clickable
	class Label < UI_Object
		include Widget::Background::Colored
		
		attr_reader :text
		
		def initialize(window, x, y, options={})
			# The actual button event is processed within Chipmunk
			options =	{
							:z_index => 0,
							:relative => window,
							
							:width => 1,
							:width_units => :px,
							:height => 1,
							:height_units => :px,
							
							:background_color => Gosu::Color::NONE,
							
							:text_align => :center, #:center, :left, :right
							:vertical_align => :middle, # :bottom, :middle, :top
							
							:font => nil,	# Font object used to render text
							:text => nil,	# Text to be rendered on this label
							:color => Gosu::Color::WHITE
						}.merge! options
			
			if options[:relative] != window
				options[:z_index] += options[:relative].pz + 1
			end
			
			super(window, options[:z_index])
			
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
			
			mass = 100
			moment = 100
			
			#~ @body = CP::Body.new_static()
			@body = CP::Body.new(mass, moment)
			@shape = Physics::Shape::Rect.new self, @body, @width, @height
			
			@shape.collision_type = :button
			@body.p = CP::Vec2.new(x,y)
			
			#~ init_physics [x,y], width, height, mass, moment, :button
			
			if options[:text]
				@text = options[:text]
				@font = options[:font]
				@color = options[:color]
				
				text_align options[:text_align]
				vertical_align options[:vertical_align]
			end
			
			init_background options[:background_color]
		end
		
		def update
			
		end
		
		def draw
			draw_background @pz
			if @font
				@font.draw @text, @body.p.x+@font_offset_x, @body.p.y+@font_offset_y, @pz, 1,1, @color
			end
		end
		
		def text=(arg)
			update_align = (@text.length != arg.length)
			@text = arg
			
			if update_align
				text_align @text_align
				vertical_align @vertical_align
			end
		end
		
		private
		
		def text_align(align)
			@text_align = align
			
			@font_offset_x = case align
				when :left
					0
				when :center
					(@width - @font.text_width(@text))/2
				when :right
					(@width - @font.text_width(@text))
			end
		end
		
		def vertical_align(align)
			@vertical_align = align
			
			@font_offset_y = case align
				when :top
					0
				when :middle
					(@height - @font.height)/2 + 2
					# Constant at the end may have to change
					# with font or platform
				when :bottom
					@height - @font.height+5
					# Constant at the end may have to change
					# with font or platform
			end
		end
	end
end
