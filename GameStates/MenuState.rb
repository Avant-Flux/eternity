#!/usr/bin/ruby

class MenuState < InterfaceState
	def initialize(window, space, layer, name)
		super(window, space, layer, name)
	end
	
	def update
		# Make sure the space is only updated once per frame, regardless of how
		# many InterfaceState objects there are.
	end
	
	def draw
		
	end
	
	def finalize
		
	end
end
