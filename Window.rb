#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 12.09.2009
require "rubygems"
require "gosu"
require "FPSCounter.rb" 

class Game_Window < Gosu::Window
	attr_reader :screen_x
	attr_reader :screen_y
	def initialize
		super(800, 600, false)
		self.caption = "Project Eternity"
		@fpscounter = FPSCounter.new(self)
	end
	
	def update
	end
	
	def draw
	end
end