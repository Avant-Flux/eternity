module Physics
	class Body < CP::Body
		attr_reader :gameobj
		
		def initialize(gameobj, *args)
			@gameobj = gameobj
			super(*args)
		end
	end
end
