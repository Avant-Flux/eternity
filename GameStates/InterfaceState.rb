#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

require './UI/Widgets'

class InterfaceState < GameState
	def initialize(window, space, layers, name, player)
		super(window, space, layers, name)
		@player = player
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
