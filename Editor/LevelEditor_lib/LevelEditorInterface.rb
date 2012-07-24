class LevelEditorInterface
	attr_reader :mouse, :width
	
	def initialize(window, space)
		@window = window
		@space = space
		
		@font = Gosu::Font.new window, "Trebuchet MS", 25
		
		#~ space.set_default_collision_func do
			#~ false
		#~ end
		
		#~ @mouse = MouseHandler.new space
		@compass = Compass.new	window,
								:top => :auto, :bottom => 0,
								:left => 0, :right => :auto
	end
	
	def update
		
	end
	
	def draw
		@compass.draw
		
		#~ @sidebar.draw
		#~ @sidebar_title.draw
		#~ @name_box.draw
		#~ @load.draw
		#~ @save.draw
	end
end
