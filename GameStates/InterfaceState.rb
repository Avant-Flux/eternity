#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

# Create a chipmunk space to allow easy manipulation of interface elements.
# Use a class variable so that one
class InterfaceState < GameState
	def initialize(window, space, layer, name)
		super(window, space, layer, name)
	end
	
	def update
		super
	end
	
	def draw
		
	end
	
	def finalize
		super
	end
end
