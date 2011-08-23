#!/usr/bin/ruby

#~ require 'rubygems'
#~ require 'gosu'
#~ require 'texplay'
#~ require 'chipmunk'
#~ 
#~ require 'require_all'
#~ 
#~ require_all './UI/Widgets'

class PromptState < InterfaceState
	def initialize(window, space, layers, name, open, close)
		super(window, space, layers, name, open, close)
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		@container = Widget::Div.new window, 120,120,
				:width => 500, :height => 300,
				:padding_top => 10, :padding_bottom => 10, 
				:padding_left => 10, :padding_right => 10
		
		@filefield = Widget::TextField.new window, 0,0,
				:relative => @container,
				:background_color => Gosu::Color::WHITE,
				:width => 100, :width_units => :percent, :height => @font.height,
				:text => "", :font => @font, :color => Gosu::Color::BLUE
		
		@accept = Widget::Button.new window, 0,50,
				:relative => @container, 
				:background_color => Gosu::Color::WHITE,
				:width => 100, :height => 30,
				:text => "Accept", :font => @font, :color => Gosu::Color::BLUE do
			@gc = true
			#~ @visible = false
		end
		
		@cancel = Widget::Button.new window, 120,50,
				:relative => @container, 
				:background_color => Gosu::Color::WHITE,
				:width => 100, :height => 30,
				:text => "Cancel", :font => @font, :color => Gosu::Color::BLUE do
			@gc = true
			#~ @visible = false
			#~ self.finalize
		end
		
		add_gameobject @container
		add_gameobject @filefield
		add_gameobject @accept
		add_gameobject @cancel
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
