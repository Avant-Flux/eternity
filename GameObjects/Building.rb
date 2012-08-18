# Similar to StaticObject, but contains a warp to a new level
# Thus, this object must manage the loading and saving of this 
# new zone.  
# 	Load the new zone when within the camera's load distance
# 	Save and free when outside a certain distance
# Should draw billboarded component, and provide method for drawing 
# trimetric component as well
class Building < StaticObject
	#~ @@texture_directory = File.join(Dir.pwd, "Sprites", "Buildings")
	@@texture_directory = File.join(Dir.pwd, "Development", "Sprites")
	#~ @@texture_directory = File.join(Dir.pwd, "Sprites")
	
	def initialize(window, height,width,depth, x,y,z, front_texture=nil, back_texture=nil)
		# Physics init
		# Door init
		# Establish level to load
		# 	Perhaps use metaprogramming interface for clean decedent implementation
		@window = window
		@front_texture = load_texture front_texture
		@back_texture = load_texture back_texture
		
		super(window, height, width, depth, x,y,z)
		
		
	end
	
	def draw_billboarded
		super()
		
		if @front_texture
			z = 0
			scale = 1
			#~ color = Gosu::Color.rgba(255,255,255, 100)
			
			pos = @body.p.to_screen
			
			@front_texture.draw_rot	pos.x, pos.y-@height.to_px-426,
									z_index, 0, 0,0, scale,scale
			
			#~ c = Gosu::Color::RED
			#~ @window.translate 0, -@height.to_px do
				#~ @window.draw_quad	pos.x, pos.y, c,
									#~ pos.x+@width.to_px, pos.y, c,
									#~ pos.x+@width.to_px, pos.y+@depth.to_px, c,
									#~ pos.x, pos.y+@depth.to_px, c,
									#~ 1000
			#~ end
		end
	end
	
	# Load the contents of the building
	def load
		
	end
	
	# Save the contents of the building to the disk
	def save
		
	end
	
	private
	
	def load_texture(name)
		puts "filename: #{name}"
		
		path = File.join @@texture_directory, "#{name}.png"
		puts path
		
		texture = nil
		if File.exist? path
			puts "loaded"
			texture = Gosu::Image.new @window, path, false
		end
		
		return texture
	end
end
