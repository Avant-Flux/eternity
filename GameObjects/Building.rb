#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

require './Drawing/Wireframe'

class Building
	include Physics::ThreeD_Support
	
	attr_reader :shape

	def initialize(window, options={})
		#~ Set default values for hash values if they are not already set.
		options[:position] ||= [0.0,0.0,0.0]
		options[:mass] ||= :static
		options[:moment] ||= :static
		options[:collision_type] = :building
		
		init_physics	:box, options[:position], options
		@height = options[:height]
		
		@wireframe = Wireframe::Box.new window, self
	end
	
	def update
		#~ @wireframe.update
	end
	
	def draw(zoom)
		@wireframe.draw zoom
	end
	
	# Overwrite height from Physics::Dimentions::ThreeD for objects without animations
	def height(units)
		if units == :meters
			@height
		else
			@height.to_px
		end
	end
end
