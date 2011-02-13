#!/usr/bin/ruby
 
module Physics
	class Space
		def initialize
			@space = CP::Space.new
		end
		
		def add(physics_obj)
			distinct = physics_obj.distinct_render?
		
			#Add body to space
			@space.add_body physics_obj.bottom.body
			@space.add_body physics_obj.side.body
			@space.add_body physics_obj.render_object.body unless distinct
			
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? MovableObject
				#Object is nonstatic
				@space.add_shape physics_obj.bottom
				@space.add_shape physics_obj.side
				@space.add_shape physics_obj.render_object unless distinct
			else
				#Object is static
				@space.add_static_shape physics_obj.bottom
				@space.add_static_shape physics_obj.side
				@space.add_static_shape physics_obj.render_object unless distinct
			end
		end
		
		def remove
			
		end
		
		def find
			
		end
	end
end
