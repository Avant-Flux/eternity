#!/usr/bin/ruby

begin
  # In case you use Gosu via rubygems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
begin
	require 'lib/gosu'
rescue LoadError
	require 'gosu'
end
require 'chingu'

require 'chipmunk'
require 'Chipmunk/Space_3D'
require 'Chipmunk/EternityMod'

require 'GameObjects/Building'
require 'GameObjects/Entity'
require "GameObjects/Creature"
require 'GameObjects/Character'
require 'GameObjects/Player'
require 'GameObjects/Camera'

require 'Utilities/FPSCounter'
require 'Utilities/InputHandler'
require 'Drawing/Animations'
require 'Drawing/Background'

require 'UI/UserInterface'

class Gosu::Image
   alias_method :rows, :height
   alias_method :columns, :width
end

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
		entity = Entity.new("Bob", @animations, [0, 0, 0], :down, 1, 10, 10, :none, 
					[1,1,1,1,1,1,1], 0)
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
		e1 = Entity.new("Bob", @animations, [0, 0, 0], :down, 1, 10, 10, :fire, 
					[1,1,1,1,1,1,1], 0)
		e2 = Entity.new("Bob", @animations, [0, 0, 0], :down, 1, 10, 10, :water, 
					[1,1,1,1,1,1,1], 0)
		e3 = Creature.new("Bob", @animations, [0, 0, 0], :down, 1, 10, 10, :lightning, 
					[1,1,1,1,1,1,1], 0)
		e4 = Player.new("Bob", @animations, [0, 0, 0])
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
		attacker = Entity.new("Bob", @animations, [0, 0, 0], :down, 1, 10, 10, :none, 
					[10,1,1,1,1,1,1], 0)
		defender = Entity.new("Bob", @animations, [0, 0, 0], :down, 1, 10, 10, :none, 
					[1,1,1,1,1,1,1], 0)
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
	
	module Test_splice
		class T < Gosu::Window
			def	initialize
				super(800, 600, false)
				self.caption = "Project ETERNITY"
				
				body = 1
				face = 1
				hair = 1
				footwear = "shoes1"
				upper = "shirt1"
				lower = "pants1"
				
				Dir.chdir("./Sprites/People/") do |dir|
					@body = Gosu::Image.new(self, "./Body/#{body}.png", false)
					parts = {:face => Gosu::Image.new(self, "./Face/#{face}.png", false),
							:hair => Gosu::Image.new(self, "./Hair/#{hair}.png", false),
						:footwear => Gosu::Image.new(self, "./Footwear/#{footwear}.png", false),
							:upper => Gosu::Image.new(self, "./Upper/#{upper}.png", false),
							:lower => Gosu::Image.new(self, "./Lower/#{lower}.png", false)}
					
					parts.each_value do |part|
						@body.splice(part, 0,0, :alpha_blend => true)
					end
					
					@sprites = Gosu::Image::load_tiles(self, @body, 40, 80, false)
				end
			end
		
			def draw
				#~ @body.draw(0,0,0)
				@sprites[0].draw(0,0,0)
			end
			
			def update
				
			end
		end		
	end
	
	class Test_colorize < Gosu::Window
		
	end
	
	class Test_camera < Gosu::Window
		def	initialize
			super(800, 600, false)
			self.caption = "Project ETERNITY"
			
			@fpscounter = FPSCounter.new(self)
			@inpman = InputHandler.new
			
			@space = CP::Space_3D.new
			
		end
	
		def draw
			@fpscounter.draw
		end
		
		def update
			@fpscounter.update
		end
			
		def button_down(id)
			@inpman.button_down(id)
			
			if id == Gosu::KbEscape
				close
			end
			if id == Gosu::KbF
				@fpscounter.toggle
			end
		end
		
		def button_up(id)
			@inpman.button_up(id)
		end
	end
end

#~ Test::test_entity_creation
#~ Test::test_multiple_entity_array
#~ Test::test_title
#~ Test::test_element_based_lvl_up
#~ Test::test_melee_attack
#~ Test::Test_splice::T.new.show
Test::Test_camera.new.show
