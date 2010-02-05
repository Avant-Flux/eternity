#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 01.07.2010

class Element
	attr_reader :value

	def initialize(value)
		@value = value
	end
	
	def ==(arg)
		@value == arg
	end
end

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
	
	def down3(lvl)
		puts ((16/9.0)*lvl+(20/9.0)).floor
	end
	
	def down2(lvl)
		puts ((4/3.0)*lvl+(20/3.0)).ceil	
	end
	
	def down1(lvl)
		puts ((8/9.0)*lvl+(100/9.0)).floor
	end
end

class Fire < Element
	include StatRates
	
	def compute_hp(lvl)
		up2(lvl)
	end
	
	def compute_mp(lvl)
		flat(lvl)
	end
	
	def compute_str(lvl)
		up1(lvl)
	end
	
	def compute_con(lvl)
		down3(lvl)
	end
	
	def compute_dex(lvl)
		down1(lvl)
	end
	
	def compute_agi(lvl)
		flat(lvl)
	end
	
	def compute_mnd(lvl)
		up3(lvl)
	end
	
	def compute_per(lvl)
		down2(lvl)
	end
	
	def compute_luk(lvl)
		up4(lvl)
	end
end

class Water < Element
	include StatRates
	
	def compute_hp(lvl)
		down2(lvl)
	end
	
	def compute_mp(lvl)
		flat(lvl)
	end
	
	def compute_str(lvl)
		flat(lvl)
	end
	
	def compute_con(lvl)
		down1(lvl)
	end
	
	def compute_dex(lvl)
		up1(lvl)
	end
	
	def compute_agi(lvl)
		up4(lvl)
	end
	
	def compute_mnd(lvl)
		up2(lvl)
	end
	
	def compute_per(lvl)
		up3(lvl)
	end
	
	def compute_luk(lvl)
		down3(lvl)
	end
end


class Lightning < Element
	include StatRates
	
	def compute_hp(lvl)
		down3(lvl)
	end
	
	def compute_mp(lvl)
		down2(lvl)
	end
	
	def compute_str(lvl)
		up4(lvl)
	end
	
	def compute_con(lvl)
		flat(lvl)
	end
	
	def compute_dex(lvl)
		down1(lvl)
	end
	
	def compute_agi(lvl)
		up2(lvl)
	end
	
	def compute_mnd(lvl)
		up3(lvl)
	end
	
	def compute_per(lvl)
		flat(lvl)
	end
	
	def compute_luk(lvl)
		up1(lvl)
	end
end

class Wind < Element
	include StatRates
	
	def compute_hp(lvl)
		flat(lvl)
	end
	
	def compute_mp(lvl)
		up4(lvl)
	end
	
	def compute_str(lvl)
		down2(lvl)
	end
	
	def compute_con(lvl)
		down2(lvl)
	end
	
	def compute_dex(lvl)
		up2(lvl)
	end
	
	def compute_agi(lvl)
		up1(lvl)
	end
	
	def compute_mnd(lvl)
		down3(lvl)
	end
	
	def compute_per(lvl)
		up3(lvl)
	end
	
	def compute_luk(lvl)
		flat(lvl)
	end
end

class Earth < Element
	include StatRates
	
	def compute_hp(lvl)
		up3(lvl)
	end
	
	def compute_mp(lvl)
		up4(lvl)
	end
	
	def compute_str(lvl)
		flat(lvl)
	end
	
	def compute_con(lvl)
		up2(lvl)
	end
	
	def compute_dex(lvl)
		down3(lvl)
	end
	
	def compute_agi(lvl)
		down1(lvl)
	end
	
	def compute_mnd(lvl)
		flat(lvl)
	end
	
	def compute_per(lvl)
		up1(lvl)
	end
	
	def compute_luk(lvl)
		down2(lvl)
	end
end

e = Element.new(:fire)