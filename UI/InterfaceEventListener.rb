class InterfaceEventListener
	def initialize
		
	end
	
	def mouse_down(*args, &block)
		# Click event released
		# Collision pre_solve and mouse button down
		
	end
	
	def mouse_up(*args, &block)
		# Click event
		# Collision pre_solve and mouse button NOT down
		
	end
	
	def mouse_in(*args, &block)
		# Mouse is over widget
		# Collision begin
		
	end
	
	def mouse_out(*args, &block)
		# Mouse has moved away from the widget
		# Collision separate
		
	end
	
	
	# ===== Collision Handler Interface Methods =====
	def begin
		
	end
	
	def pre_solve
		
	end
	
	def post_solve
		
	end
	
	def separate
		
	end
end
