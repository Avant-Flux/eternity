# Similar to StaticObject, but contains a warp to a new level
# Thus, this object must manage the loading and saving of this 
# new zone.  
# 	Load the new zone when within the camera's load distance
# 	Save and free when outside a certain distance
# Should draw billboarded component, and provide method for drawing 
# trimetric component as well
class Building < StaticObject
	@@texture_directory = File.join(Dir.pwd, "Sprites", "Buildings")
	
	def initialize(window, height,width,depth, x,y,z, front_texture=nil, back_texture=nil)
		# Physics init
		# Door init
		# Establish level to load
		# 	Perhaps use metaprogramming interface for clean decedent implementation
		
		super(window, height, width, depth, x,y,z)
		
		@front_texture = load_texture front_texture
		@back_texture = load_texture back_texture
	end
	
	# Load the contents of the building
	def load
		
	end
	
	# Save the contents of the building to the disk
	def save
		
	end
	
	private
	
	def load_texture(name)
		path = File.join @@texture_directory, name
		puts path
		
		texture = nil
		if path != @@texture_directory
			puts "No texture"
		else
			if File.exist? path
				texture = Gosu::Image.new @window, path, false
			end
		end
		
		return texture
	end
end
