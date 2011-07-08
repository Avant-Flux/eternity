#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

require './Drawing/Wireframe'

class Building
	include Physics::ThreeD_Support
	
	attr_reader :shape

	def initialize(window, options={})
		#~ Set default values for hash values if they are not already set.
		options[:dimensions] ||= [1.0,1.0,1.0]
		options[:position] ||= [0.0,0.0,0.0]
		
		init_physics	:box, options[:position], :width => 2, :height => 3, :depth => 2,
						:mass => :static, :moment => :static, :collision_type => :entity
		
		@wireframe = Wireframe::Box.new window, self
	end
	
	def update
		#~ @wireframe.update
	end
	
	def draw
		@wireframe.draw
	end
end
