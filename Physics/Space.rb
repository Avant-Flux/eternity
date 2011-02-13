#!/usr/bin/ruby
 
module Physics
	class Space
		def initialize
			@space = CP::Space.new
		end
		
		def add(physics_obj)
			#Add body to space
			@space.add_body physics_obj.bottom.body
			@space.add_body physics_obj.side.body
			
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? MovableObject
				#Object is nonstatic
				@space.add_shape physics_obj.bottom
				@space.add_shape physics_obj.side
			else
				#Object is static
				
				#Static objects also have a render object which must be added
				@space.add_body physics_obj.render_object.body
				
				@space.add_static_shape physics_obj.bottom
				@space.add_static_shape physics_obj.side
				@space.add_static_shape physics_obj.render_object
			end
		end
		
		def remove
			
		end
		
		def find
			
		end
	end
end
