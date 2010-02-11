#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 02.11.2010

require "Entity"
require "Character"
require "Player"

require "NPC"

require "Creature"

#~ require "Constants"

require "rubygems"
require "gosu"

class Character
	def ls element
		current_lvl = @lvl
		self.lvl = 1
	
		puts "LVL | HP   MP   | STR CON DEX AGI MND PER LUK"
		ls_stats
		
		9.times do
			lvl_up
			ls_stats
		end
		
		@element = element
		
		90.times do
			lvl_up
			ls_stats
		end
		
		self.lvl = current_lvl
	end
	
	private 
	
	def ls_stats	
		printf("%-3d | %-4d %-4d | %-3d %-3d %-3d %-3d %-3d %-3d %-3d\n", 
					@lvl, @hp, @mp, @str, @con, @dex, @agi, @mnd, @per, @luk)
	end
end

#~ require 'ruby-debug'
#~ debugger

module Test
	module Movement
		Up = 2
		Down = 3
		Left = 5
		Right = 7
		Up_right = Up * Right
		Up_left = Up * Left
		Down_right = Down * Right
		Down_left = Down * Left
	end
	
	def test_entity_creation
		animations = {:up => 1,
					:down => 2,
					:left => 3,
					:right => 4,
					:up_right => 5,
					:up_left => 6,
					:down_right => 7,
					:down_left => 8}
		
		entity = Entity.new(animations, pos=[0, 0, 0], lvl=1, hp=10, mp=10, element=:none, 
					stats=[1,1,1,1,1,1,1], faction = 0)
		character = Character.new(animations)
		player = Player.new(animations)
		creature = Creature.new(animations)
		
		p entity
		puts
		p character
		puts
		p player
		puts
		p creature
	end
	
	def test_title
		player = Player.new(animations)
		player.titles << (Title.new("sue", "this is sue", 1, 100))
		player.titles << (Title.new("bob", "this is bob", 1, 200))
		p player
						puts ""
		player.titles.sort! :points
		p player
	end
	
	def test_element_based_lvl_up
		p = Player.new(animations)
		puts "Fire"
		p.ls :fire
		print "\n\n\n"
		puts "Water"
		p.ls :water
		print "\n\n\n"
		puts "Wind"
		p.ls :wind
		print "\n\n\n"
		puts "Lighting"
		p.ls :lightning
		print "\n\n\n"
		puts "Earth"
		p.ls :earth
	end
end
