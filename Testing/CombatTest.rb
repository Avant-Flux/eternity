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
		
		@player = Player.new self, "Bob"
		@player.equipment[:right_hand] = Weapons::Swords::Scimitar.new
		@player.equipment[:left_hand] = Weapons::Guns::Handgun.new
		
		@bat = Creatures::Bat.new "bat1"
	end
	
	def update
		
	end
	
	def draw
		#~ @player.draw 10
		# Display player stats
		@font.draw "#{@player.name}", 10, 10, 0
		@font.draw "#{@player.hp[:current]} / #{@player.hp[:max]}", 10, 30, 0
		@font.draw "#{@player.mp[:current]} / #{@player.mp[:max]}", 10, 50, 0
		
		# Draw monster stats
		
	end
	
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
	end
	
	def button_up(id)
		
	end
	
	def needs_cursor?
		true
	end
end

CombatTest.new.show
