#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 04.18.2010

require "Entity"
require "Character"
require "Player"

require "NPC"

require "Creature"

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
	
	@animations = {:up => 1,
					:down => 2,
					:left => 3,
					:right => 4,
					:up_right => 5,
					:up_left => 6,
					:down_right => 7,
					:down_left => 8}
	
	class << self
	def test_entity_creation
		entity = Entity.new("Bob", @animations, pos=[0, 0, 0], lvl=1, hp=10, mp=10, element=:none, 
					stats=[1,1,1,1,1,1,1], faction = 0)
		character = Character.new("Bob", @animations)
		player = Player.new("Bob", @animations)
		creature = Creature.new("Bob", @animations)
		
		p entity
		puts
		p character
		puts
		p player
		puts
		p creature
	end
	
	def test_multiple_entity_array
		e1 = Entity.new("Bob", @animations, pos=[0, 0, 0], lvl=1, hp=10, mp=10, element=:fire, 
					stats=[1,1,1,1,1,1,1], faction = 0)
		e2 = Entity.new("Bob", @animations, pos=[0, 0, 0], lvl=1, hp=10, mp=10, element=:water, 
					stats=[1,1,1,1,1,1,1], faction = 0)
		e3 = Creature.new("Bob", @animations, pos=[0, 0, 0], lvl=1, hp=10, mp=10, element=:lightning, 
					stats=[1,1,1,1,1,1,1], faction = 0)
		e4 = Player.new("Bob", @animations, pos=[0, 0, 0])
		p Entity.all
	end
	
	def test_title
		player = Player.new("Bob", @animations)
		
		player.titles << (Title.new("sue", "this is sue", 1, 100))
		player.titles << (Title.new("bob", "this is bob", 1, 200))
		
		p player.titles
		
		puts
		
		player.titles.sort! :points
		p player.titles
	end
	
	def test_element_based_lvl_up	
		p = Player.new("Bob", @animations)
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
	
	def test_melee_attack
		attacker = Entity.new("Bob", @animations, pos=[0, 0, 0], lvl=1, hp=10, mp=10, element=:none, 
					stats=[10,1,1,1,1,1,1], faction = 0)
		defender = Entity.new("Bob", @animations, pos=[0, 0, 0], lvl=1, hp=10, mp=10, element=:none, 
					stats=[1,1,1,1,1,1,1], faction = 0)
		10.times do
			p attacker.melee_attack defender
		end
	end
	
	def test_draw
		#~ x = y = 20
		#~ @animations.each do |a|
			#~ a.draw(x, y, 1, 1, 1)
			#~ x += 80 
			#~ y += 85
		#~ end
	end
	
	end
end

#~ Test::test_entity_creation
#~ Test::test_multiple_entity_array
#~ Test::test_title
#~ Test::test_element_based_lvl_up
#~ Test::test_melee_attack
	
