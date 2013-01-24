module Component
	class Animation
		# The update method of Oni::Agent exists to update animations
		# delegate :update, :base_animation, :top_animation, :to => @model
		# delegate_to @model, :update, :base_animation, :top_animation
		
		def initialize(model)
			@model = model
		end
		
		def update(dt)
			@model.update
		end
		
		def top=(name)
			@model.top_animation = name
		end
		
		def base=(name)
			@model.base_animation = name
		end
		
		def top
			@model.top_animation
		end
		
		def base
			@model.base_animation
		end
	end
end