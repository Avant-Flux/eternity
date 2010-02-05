#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 01.24.2010

require "Entity"
#To be used for NPCs, such as enemy units
#Townspeople (ie shopkeeper etc) should be under a different class
class Character < Entity
	attr_accessor :charge, :str, :con
	attr_accessor :inventory, :equipment
	
	def initialize(animations, pos = [0, 0, 0])
		super(animations, pos, lvl=1, hp=10, mp=10, element = :none, 
				stats = [10, 10, 10, 10, 10, 10, 10], faction = 0)
				
		@str = stats[0]
		@con = stats[1]
		
		@charge = 0			#0 is normal, 1 is fired-up, -1 is suppressed
		@inventory = {:consumable => [], :equipable => [], :key_items => []}
		@equipment =	{:head => nil, :right_hand => nil, :left_hand => nil, 
						:upper_body => nil, :lower_body => nil, :feet => nil, :title => nil}
	end
	
	def lvl=(arg)
		@lvl = arg
		
		set_stats
		
		@hp = @max_hp
		@mp = @max_mp
	end
	
	def use_item
		
	end
	
	private
	
	def set_atk
		@atk = @str + @equipment[:right_hand].atk + @equipment[:left_hand].atk
	end
	
	def set_def
		@def = @con + @equipment[:right_hand].def + @equipment[:left_hand].def + 
				@equipment[:head].def + @equipment[:upper_body].def + @equipment[:lower_body].def +
				@equipment[:feet].def
	end
	
	def set_stats
		if lvl > 10
			compute_hp
			compute_mp
			compute_str
			compute_con
			compute_dex
			compute_agi
			compute_mnd
			compute_per
			compute_luk
		else
			stats_to_10
		end
	end
	
	def stats_to_10
		@max_hp = @max_mp = @str = @con = @dex = @agi = @mnd = @per = @luk = 
			if @lvl < 10
				@lvl+9
			else
				20
			end
	end
	
	def compute_hp
		@max_hp = case @element
			when :fire
				up2
			when :water
				down2
			when :lightning
				down3
			when :wind
				flat
			when :earth
				up3
		end
	end
	
	def compute_mp
		@max_mp = case @element
			when :fire
				flat
			when :water
				flat
			when :lightning
				down2
			when :wind
				up4
			when :earth
				up4
		end
	end
	
	def compute_str
		@str = case @element
			when :fire
				up1
			when :water
				flat
			when :lightning
				up4
			when :wind
				down2
			when :earth
				flat
		end
	end
	
	def compute_con
		@con = case @element
			when :fire
				down3
			when :water
				down1
			when :lightning
				flat
			when :wind
				down2
			when :earth
				up2
		end
	end
	
	def compute_dex
		@dex = case @element
			when :fire
				down1
			when :water
				up1
			when :lightning
				down1
			when :wind
				up2
			when :earth
				down3
		end
	end
	
	def compute_agi
		@agi = case @element
			when :fire
				flat
			when :water
				up4
			when :lightning
				up2
			when :wind
				up1
			when :earth
				down1
		end
	end
	def compute_mnd
		@mnd = case @element
			when :fire
				up3
			when :water
				up2
			when :lightning
				up3
			when :wind
				down3
			when :earth
				flat
		end
	end
	
	def compute_per
		@per = case @element
			when :fire
				down2
			when :water
				up3
			when :lightning
				flat
			when :wind
				up3
			when :earth
				up1
		end
	end
	
	def compute_luk
		@luk = case @element
			when :fire
				up4
			when :water
				down3
			when :lightning
				up1
			when :wind
				flat
			when :earth
				down2
		end
	end
	#~ 
	def up1
		((43/9.0)*@lvl-(250/9.0)).floor
	end
	
	def up2
		((38/9.0)*@lvl-(200/9.0)).floor
	end
	
	def up3
		((10/3.0)*@lvl-(40/3.0)).floor
	end
	
	def up4
		((20/9.0)*@lvl-(20/9.0)).floor
	end
	
	def flat
		2*@lvl
	end
	
	def down1
		((16/9.0)*@lvl+(20/9.0)).floor
	end
	
	def down2
		((4/3.0)*@lvl+(20/3.0)).ceil	
	end
	
	def down3
		((8/9.0)*@lvl+(100/9.0)).floor
	end
end