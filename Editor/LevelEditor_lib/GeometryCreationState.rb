class GeometryCreationstate < LevelEditorInterface
	def initialize

	end
	
	def update

	end
	
	def draw

		
	end

	
	{
		:add_widgets_to_space => :add_to_space,
		:remove_widgets_from_space => :remove_from_space,
	}.each do |interface_method, backend_method|
		define_method interface_method do
			#self.send backend_method, @stuff
		end
	end

end
