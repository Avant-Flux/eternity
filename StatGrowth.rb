#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 01.05.2010

#~ Functions now give the value of the stat at a given lvl.

module StatRates
	def up1(lvl)
		puts ((43/9.0)*lvl-(250/9.0)).floor
	end
	
	def up2(lvl)
		puts ((38/9.0)*lvl-(200/9.0)).floor
	end
	
	def up3(lvl)
		puts ((10/3.0)*lvl-(40/3.0)).floor
	end
	
	def up4(lvl)
		puts ((20/9.0)*lvl-(20/9.0)).floor
	end
	
	def flat(lvl)
		puts 2*lvl
	end
	
	def down1(lvl)
		puts ((16/9.0)*lvl+(20/9.0)).floor
	end
	
	def down2(lvl)
		puts ((4/3.0)*lvl+(20/3.0)).ceil	
	end
	
	def down3(lvl)
		puts ((8/9.0)*lvl+(100/9.0)).floor
	end
end


x = 10
(1..100).each do |lvl|
	if lvl == 1
		puts x
	elsif lvl > 1 && lvl < 10
		x+=1
		puts x
	elsif lvl == 10
		x+=2
		puts x
	else
		#~ puts ().floor
		#~ puts ((16/9.0)*lvl-(20/9.0)).floor
		puts ((8/9.0)*lvl+(100/9.0)).floor
	end
end