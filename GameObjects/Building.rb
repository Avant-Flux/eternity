#!/usr/bin/ruby

require 'rubygems'
require 'gosu'

require './Drawing/Wireframe'

class Building
	attr_reader :shape

	def initialize(options={})
		#~ Set default values for hash values if they are not already set.
		options[:dimensions] ||= [1.0,1.0,1.0]
		options[:position] ||= [0.0,0.0,0.0]
		
		@physics = Physics::EnvironmentObject.new(self, options[:position], options[:dimensions])

		@wireframe = $art_manager.new_wireframe @physics, :white
		
		$space.add @physics
	end
	
	def update
		#~ @wireframe.update
	end
	
	def draw
		@wireframe.draw(@shape)
	end
	
	def width
		@physics.width
	end
	
	def depth
		@physics.depth
	end
	
	def height
		@physics.height
	end
	
	def width= arg
		@physics.width = arg
	end
	
	def depth= arg
		@physics.depth = arg
	end
	
	def height= arg
		@physics.height = arg
	end
end
