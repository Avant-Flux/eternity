class InterfaceEventListener
	def initialize(mouse)
		@mouse = mouse
	end
	
	[:mouse_down, :mouse_up, :mouse_in, :mouse_out].each do |method|
		define_method method do |*args, &block|
			instance_variable_set "@#{method}", block
			instance_variable_set "@#{method}_args", args
		end
	end
	
	# ===== Collision Handler Interface Methods =====
	def begin(arbiter)
		if @mouse_in
			@mouse_in.call @mouse_in_args
		end
	end
	
	def pre_solve(arbiter)
		if @mouse_down # && @mouse.button_down
			@mouse_down.call @mouse_down_args
		elsif @mouse_up # && @mouse.button_up
			@mouse_up.call @mouse_up_args
		end
	end
	
	def post_solve(arbiter)
		
	end
	
	def separate(arbiter)
		if @mouse_out
			@mouse_out.call @mouse_out_args
		end
	end
end
