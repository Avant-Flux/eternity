#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'chipmunk'

require 'require_all'

#~ require_all './UI/Widgets'

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
		@gameobjects.each do |obj|
			obj.draw
		end
	end
	
	def finalize
		super
	end
end
