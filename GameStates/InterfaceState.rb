#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

require 'require_all'

require_all './UI/Widgets'

class InterfaceState < GameState
	def initialize(window, space, layers, name, open, close)
		super(window, space, layers, name)
		@open = open
		@close = close
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
