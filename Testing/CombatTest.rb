#!/usr/bin/ruby

path = File.expand_path File.dirname(__FILE__)
path = path[0..(path.rindex(File::SEPARATOR))]
Dir.chdir path

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
require 'require_all'

require_all './Physics'
require_all './GameObjects'
require_all './Equipment'
#~ require_all './GameStates'
require_all './Utilities'
require_all './Drawing'
require_all './UI'

class CombatTest < Gosu::Window
	def initialize
		fps = 60
		# Window should have a 16:9 aspect ratio
		super(1100, 619, false, (1.0/fps)*1000)
		self.caption = "Animation Editor"
		
		Cacheable.sprite_directory = "./Sprites"
		
		@font = Gosu::Font.new self, "Trebuchet MS", 25
		
		@player = Player.new self, "Fire Character", [0,0,0], {}, 
				{:strength =>		12,
				:constitution =>	9,
				:dexterity =>		6, 
				:power =>			6,
				:skill =>			3,
				:flux =>			9}
		
		@player.equipment[:right_hand] = Weapons::Swords::Scimitar.new
		@player.equipment[:left_hand] = Weapons::Guns::Handgun.new
		
		
		@monsters = []
		@monsters << Creatures::Bat.new(self, "bat1")
		@monsters << Creatures::Bat.new(self, "bat2")
		@monsters << Creatures::Bat.new(self, "bat3")
		@monsters << Creatures::Bat.new(self, "bat4")
		@monsters << Creatures::Bat.new(self, "bat5")
	end
	
	def update
		
	end
	
	def draw
		#~ @player.draw 10
		# Display player stats
		if @player.hp[:current] > 0
			@font.draw "#{@player.name}", 10, 10, 0
			@font.draw "#{@player.hp[:current]} / #{@player.hp[:max]}", 10, 30, 0
			@font.draw "#{@player.mp[:current]} / #{@player.mp[:max]}", 10, 50, 0
		else
			@font.draw "#{@player.name}", 10, 10, 0
			@font.draw "is dead", 10, 30, 0
		end
		
		# Draw monster stats
		@monsters.each_with_index do |monster, i|
			@font.draw "#{monster.name}", 200*(i+1), 10, 0
			@font.draw "#{monster.hp[:current]} / #{monster.hp[:max]}", 200*(i+1), 30, 0
			@font.draw "#{monster.mp[:current]} / #{monster.mp[:max]}", 200*(i+1), 50, 0
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			when Gosu::KbReturn
				step
		end
	end
	
	def button_up(id)
		
	end
	
	def needs_cursor?
		true
	end
	
	def step
		# Player attacks
		if @player.hp[:current] > 0
			@player.melee_attack @monsters[0]
		end
		
		# Monster attack
		unless @monsters.empty?
			@monsters.each_with_index do |monster, i|
				#~ @player.melee_attack monster
				monster.melee_attack @player
			end
		end
		
		# Clean up
		if @monsters[0]
			puts @monsters[0].hp[:current]
				
			if @monsters[0].hp[:current] == 0
				@monsters.shift
			end
		end
	end
end

CombatTest.new.show
