#!/usr/bin/ruby
module Equipable
	def apply_effect(player)
		player
	end
	
	def remove_effect(player)
		player
	end
end


module Headgear
	include Equipable
	
	class Hat
		attr_reader :defence
		
		def initialize
			@defence = 1
		end
	end
	
	class Helmet
		
	end
	
	class Mask
		
	end
end

module Upper
	include Equipable
	
	class Shirt
		attr_reader :defence
		
		def initialize
			@defence = 1
		end
	end
	
	class Armor
		
	end
end

module Lower
	include Equipable
	
	class Pants
		attr_reader :defence
		
		def initialize
			@defence = 1
		end
	end
	
	class Skirt
		
	end
end

module OuterWear
	class Trenchcoat
		attr_reader :defence
		
		def initialize
			@defence = 1
		end
	end
end

module Footgear
	include Equipable
	
	class Shoes
		attr_reader :defence
		
		def initialize
			@defence = 1
		end
	end
	
	class Sandals
		
	end
	
	class Boots
		
	end
end

module Weapons
	module Axes
		
	end
	
	module Swords
		class Scimitar
			attr_accessor :durability, :charge_time, :charge
			attr_reader :attack
			
			def initialize
				@durability = {:current => 100, :max => 100}
				@charge_time = 2000
				@charge = false
				
				@attack = 2
			end
		end
	end
	
	module Daggers
		
	end
	
	module Maces
		
	end
	
	module Clubs
		
	end
	
	module Knuckles
		
	end
	
	module Guns
		class Handgun
			attr_accessor :durability, :charge_time, :charge
			attr_reader :attack
			
			def initialize
				@durability = {:current => 100, :max => 100}
				@charge_time = 2000
				@charge = false
				
				@attack = 3
			end
		end
		
		class Revolver
			
		end
		
		class Shotgun
			
		end
	end
end
