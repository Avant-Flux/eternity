class LevelEditorInterface
	attr_reader :mouse, :width
	attr_reader :sidebar
	
	def initialize(window, space, font)
		@window = window
		@space = space
		@font = font
	end
	
	def update
		if @window.mouse_x >= @sidebar.body.p.x
			@window.selected_cursor = :menu
		end
	end
	
	def draw
		
	end
	
	def click(mouse_x,mouse_y)
		# TODO: Click events should only trigger for UI widget with highest z index
		@space.point_query CP::Vec2.new(mouse_x,mouse_y) do |target|
			if target.gameobject.respond_to? :on_click 
				puts "target: #{target.gameobject}"
				target.gameobject.on_click
			end
		end
	end
	
	private
	
	def add_to_space(widget)
		@space.add_static_shape widget.shape
	end
end
