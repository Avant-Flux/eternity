#!/usr/bin/ruby
 
module Physics
	class Space
		def initialize(dt)
			@space = CP::Space.new
			@dt = dt
		end
		
		def add(physics_obj)
			#Add body to space
			@space.add_body physics_obj.bottom.body
			@space.add_body physics_obj.side.body
			
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? NonstaticObject
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
		
		def remove(physics_obj)
			#Add body to space
			@space.remove_body physics_obj.bottom.body
			@space.remove_body physics_obj.side.body
			
			#Add shape to space.  This depends on whether or not the shape is static.
			if physics_obj.is_a? NonstaticObject
				#Object is nonstatic
				@space.remove_shape physics_obj.bottom
				@space.remove_shape physics_obj.side
			else
				#Object is static
				
				#Static objects also have a render object which must be added
				@space.remove_body physics_obj.render_object.body
				
				@space.remove_static_shape physics_obj.bottom
				@space.remove_static_shape physics_obj.side
				@space.remove_static_shape physics_obj.render_object
			end
		end
		
		def find
			
		end
		
		def step
			@space.step @dt
		end
	end
end
