#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

require './Drawing/Wireframe'

class Building
	include Physics::ThreeD_Support
	include Physics::ThreeD_Support::Box
	
	attr_reader :shape

	def initialize(window, position, dimensions, options={})
		#~ Set default values for hash values if they are not already set.
		options[:mass] ||= :static
		options[:moment] ||= :static
		options[:collision_type] = :building
		
		#~ init_physics	:box, options[:position], options
		#~ init_physics	position, dimensions, options
		init_physics	position, dimensions, :static, :static, :building
		
		@wireframe = Wireframe::Box.new window, self
		
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
	
	def draw(zoom)
		@wireframe.draw zoom
		# Render building shadow
	end
end
