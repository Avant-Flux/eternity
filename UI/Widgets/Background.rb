#!/usr/bin/ruby
require 'rubygems'
require 'gosu'
require 'chipmunk'

module Widget
	# Mix in which specifies behaviors for drawing different kinds of backgrounds
	module Background
		module Colored
			def init_background(color)
				@background_color = color # Gosu::Color format
				
				@verts = []
				@shape.each_vertex_absolute do |vertex|
					@verts << vertex
				end
			end
			
			def draw_background(z)
				@verts = []
				@shape.each_vertex_absolute do |vertex|
					@verts << vertex
				end
				@window.draw_quad	@verts[0].x, @verts[0].y, @background_color,
									@verts[1].x, @verts[1].y, @background_color,
									@verts[2].x, @verts[2].y, @background_color,
									@verts[3].x, @verts[3].y, @background_color, z
			end
		end
		
		module Image
			def init_background(img)
				@background_image = img
			end
			
			def draw_background(x,y,z)
				@background_image.draw x, y, z
			end
		end
	end
end
