#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 12.20.2009

require "Title"
require "Title_Holder"
require "Character"
#Defines the player-controlled character
	#Only define attributes in this class that are PC specific
		#IE input-driven movement, mechanics of leveling up, etc
class Player < Character
	attr_reader :lvl_cap, :titles
	@stat_formulae

	def initialize(animations, pos = [0, 0, 0])
							
		super(animations, pos, lvl=1, hp=10, mp=10, element=:none, 
				stats= [10, 10, 10, 10, 10, 10, 10], faction=0)
		
		@titles = Title_Holder.new
		set_stat_tree
	end
	
	def element=(elem)
		@element = elem
		set_stat_tree
	end
	
	def lvl_up		
		inc_all_stats @stat_tree[@lvl.magnitude]
		
		#Refill HP and MP fully on level up
		@hp = @max_hp
		@mp = @max_mp
	end
	
	def give_title(t)
		@titles << t
		@titles.sort!(:name)
	end
	
	private
	def @lvl.magnitude
		#Returns the next largest power of ten
		#ex		5 returns 10; 16 returns 20, 20 returns 20
		(@lvl/10.0).ceil * 10
	end
	
	def inc_all_stats(increments)
		inc_max_hp increments[0]
		inc_max_mp increments[1]
		inc_str increments[2]
		inc_con increments[3]
		inc_dex increments[4]
		inc_agi increments[5]
		inc_mnd increments[6]
		inc_per increments[7]
	end
	
	def inc_max_hp(increment)
		@max_hp += increment
	end
	
	def inc_max_mp(increment)
		@max_mp += increment
	end
	
	def inc_str(increment)
		@str += increment
	end
	
	def inc_con(increment)
		@con += increment
	end
	
	def inc_dex(increment)
		@dex += increment
	end
	
	def inc_agi(increment)
		@agi += increment
	end
	
	def inc_mnd(increment)
		@mnd += increment
	end
	
	def inc_per(increment)
		@per += increment
	end
end