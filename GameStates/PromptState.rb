#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'texplay'
require 'chipmunk'

require 'require_all'

require_all './UI/Widgets'

class PromptState < InterfaceState
	def initialize(window, space, layers, name, player)
		super(window, space, layers, name, player)
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		@div = Widget::Div.new window, 0,0,
				:width => 500, :height => 300,
				:padding_top => 40, :padding_bottom => 40, 
				:padding_left => 30, :padding_right => 30
		
		@filefield = Widget::TextField.new window, 0,0,
				:relative => @div,
				:background_color => Gosu::Color::WHITE,
				:width => 100, :width_units => :percent, :height => @font.height,
				:text => "", :font => @font, :color => Gosu::Color::BLUE
		
		@accept = Widget::Button.new window, 0,50,
				:relative => @div, 
				:background_color => Gosu::Color::WHITE,
				:width => 200, :height => 100,
				:text => "Accept", :font => @font, :color => Gosu::Color::BLUE do
			puts "accept"
			#~ self.visible = false
			@gc = true
		end
		
		@cancel = Widget::Button.new window, 220,50,
				:relative => @div, 
				:background_color => Gosu::Color::WHITE,
				:width => 200, :height => 100,
				:text => "Cancel", :font => @font, :color => Gosu::Color::BLUE do
			puts "cancel"
			#~ self.visible = false
			@gc = true
		end
	end
	
	def update
		@div.update
		@accept.update
		@cancel.update
		@filefield.update
	end
	
	def draw
		@div.update
		@accept.update
		@cancel.update
		@filefield.update
	end
	
	def finalize
		
	end
end
