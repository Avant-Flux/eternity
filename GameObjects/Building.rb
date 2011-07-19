#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

require './Drawing/Wireframe'

class Building
	include Physics::ThreeD_Support
	include Physics::ThreeD_Support::Box
	
	attr_reader :shape

	def initialize(window, options={})
		#~ Set default values for hash values if they are not already set.
		options[:position] ||= [0.0,0.0,0.0]
		options[:mass] ||= :static
		options[:moment] ||= :static
		options[:collision_type] = :building
		
		init_physics	options[:position], [options[:width], options[:depth], options[:height]], options
		@height = options[:height]
		
		@wireframe = Wireframe::Box.new window, self
	end
	
	def update
		#~ @wireframe.update
	end
	
	def draw(zoom)
		@wireframe.draw zoom
	end
end
