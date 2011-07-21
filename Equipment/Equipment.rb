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
		
	end
	
	class Helmet
		
	end
	
	class Mask
		
	end
end

module Upper
	include Equipable
	
	class Shirt
		
	end
	
	class Armor
		
	end
end

module Lower
	include Equipable
	
	class Pants
		
	end
	
	class Skirt
		
	end
end

module Footgear
	include Equipable
	
	class Shoes
		
	end
	
	class Sandals
		
	end
	
	class Boots
		
	end
end
