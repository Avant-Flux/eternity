#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk-ffi'

# Create a chipmunk space to allow easy manipulation of interface elements.
# Use a class variable so that one
class InterfaceState < GameState
	def initialize(window, space, layer, name)
		super(window, space, layer, name)
	end
	
	def update
		# Make sure the space is only updated once per frame, regardless of how
		# many InterfaceState objects there are.
	end
	
	def draw
		
	end
	
	def finalize
		
	end
end
