#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'

require 'set'

class MouseHandler
	attr_accessor :mode
	
	def initialize(space, layers)#, radius, mass, moment)
		@space = space
		@layers = layers
		#~ body = CP::Body.new mass, moment
		#~ @mouse_shape = CP::Shape::Circle.new body, radius
		
		#~ @mouse_shape.collision_type = :pointer
		
		#~ space.add @mouse_shape
		@active = Set.new # Stack to hold all active/selected elements
		
		@mode = :default # :default, :multiple_select, :box_select
	end
	
	def click_UI(position)
		target = nil
		@space.point_query position, @layers, CP::NO_GROUP do |shape|
			if target
				#~ puts "#{shape.gameobj.class}:#{shape.gameobj.pz} <=> #{target.gameobj.class}:#{target.gameobj.pz}"
				if shape.gameobj.pz >= target.gameobj.pz
					# Use this shape instead of the current target if it is further up the draw stack
					target = shape
				end
			else
				target = shape
			end
		end
		
		if target
			if target.gameobj.is_a? Widget::UI_Object
				# UI Object found
				
				case @mode
					when :default
						# Mark other objects as no longer active
						@active.each do |obj|
							obj.on_lose_focus
						end
						@active.clear
						
						# Call click event
						target.gameobj.on_click
						
						# Add to active set
						@active.add target.gameobj
					when :multiple_select
						# Call click event
						target.gameobj.on_click
						
						# Add to active set
						@active.add target.gameobj
					when :box_select
						
				end
			else
				put target.gameobj.class
			end
		end
	end
	
	def click_scene(position)
		# Perform a "raycast" into the scene and attempt to find a gameobject
		target = nil
		@space.point_query position, CP::ALL_LAYERS, CP::NO_GROUP do |shape|
			if shape.collision_type == :building
				target = shape
			end
		end
		
		if target
			gameobj = target.gameobj
			#~ puts gameobj.class
			
			if gameobj.is_a? Building
				gameobj.wireframe.select
			end
		end
	end
end
