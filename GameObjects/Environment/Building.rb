#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'

class Building
	include Physics::ThreeD_Support
	include Physics::ThreeD_Support::Box
	
	def initialize(window, name, position, dimensions)
		@window = window
		
		init_physics	position, dimensions, :static, :static, :building
		
		@wireframe = Wireframe::Box.new window, self
		
		#~ @texture = TextureMap::Building.new window, self, name
		# Create building shadow
		# Should have as close to the same cross-sectional area as the building as possible
		# Eventually, use the bitmap for the opengl stencil buffer used on the interior texture
		# When using the collision object, perhaps blur the edges to hide the fact that
		# the shadow is not exact.  Given the art style, even non-blurred edges
		# will most likely suffice for a while.
	end
	
	def update
		#~ @wireframe.update
	end
	
	def draw(zoom, pos, camera_origin)
		@wireframe.draw zoom, pos, camera_origin
		#~ @texture.draw zoom
		
		# Render building shadow
	end
	
	def export(path, name)
		scale = 1
		side_buffer = 4
		top_bottom_buffer = 4
		
	end
end
