#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 01.25.2010

require "Entity"
require "Character"
require "Player"

require "NPC"

require "Creature"

#~ require "Constants"

require "rubygems"
require "gosu"

class Test
	attr_reader :entity, :character, :player, :creature

	def initialize
		animations = {:up => 1,
					:down => 2,
					:left => 3,
					:right => 4,
					:up_right => 5,
					:up_left => 6,
					:down_right => 7,
					:down_left => 8}
		
		@entity = Entity.new(animations, pos=[0, 0, 0], lvl=1, hp=10, mp=10, element=:none, 
					stats=[1,1,1,1,1,1,1], faction = 0)
		@character = Character.new(animations)
		@player = Player.new(animations)
		@creature = Creature.new(animations)
	end
end

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

t = Test.new
p t.entity
puts
p t.character
puts
p t.player
puts
p t.creature

#~ t.player.titles << (Title.new("sue", "this is sue", 1, 100))
#~ t.player.titles << (Title.new("bob", "this is bob", 1, 200))
#~ p t.player
				#~ puts ""
#~ t.player.titles.sort! :points
#~ p t.player

#~ require 'ruby-debug'
#~ debugger

#~ t.player.ls :fire
animations = {:up => 1,
					:down => 2,
					:left => 3,
					:right => 4,
					:up_right => 5,
					:up_left => 6,
					:down_right => 7,
					:down_left => 8}

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