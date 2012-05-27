class InterfaceEventListener
	def initialize(mouse)
		@mouse = mouse
		@click = nil
	end
	
	[:mouse_down, :mouse_up, :mouse_in, :mouse_out, 
	:hover, :drag].each do |method|
		define_method method do |*args, &block|
			instance_variable_set "@#{method}", block
			instance_variable_set "@#{method}_args", args
		end
		
		define_method "#{method}_event" do
			instance_variable_get("@#{method}").call(instance_variable_get("@#{method}_args"))
		end
		
		define_method "#{method}?" do
			return instance_variable_get "@#{method}" != nil
		end
	end
	
	
	def drag_event_callback
		# Called on drag event
		
	end
	
	# ===== Collision Handler Interface Methods =====
	def begin(arbiter)
		if mouse_in?
			mouse_in_event
		end
	end
	
	def pre_solve(arbiter)
		if mouse_down? # && @mouse.button_down
			mouse_down_event
			@click = true
		elsif mouse_up? && @click# && !@mouse.button_down
			mouse_up_event
			@click = false
		else # hover event
			hover_event
		end
	end
	
	def post_solve(arbiter)
		
	end
	
	def separate(arbiter)
		if mouse_out?
			mouse_out_event
		end
	end
end
