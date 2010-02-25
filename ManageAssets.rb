#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 02.25.2010
require "Entity"
require "Creature"
require "Character"
require "Player"

module ManageAssets
	@animations = {:up => 1,
					:down => 2,
					:left => 3,
					:right => 4,
					:up_right => 5,
					:up_left => 6,
					:down_right => 7,
					:down_left => 8}

	def new_player
		Player.new
	end
	
	def load_player
		
	end
end
