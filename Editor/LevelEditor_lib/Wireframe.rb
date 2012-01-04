module Wireframe
	class Box
		@@show_wireframe = false
		@@show_faces = true
		
		alias :old_draw :draw
		
		def draw(camera)
			if @@show_wireframe
				draw_wireframe camera
			end
			
			if @@show_faces
				draw_faces camera
			end
		end
		
		class << self
			def show_wireframe=(arg)
				@@show_wireframe = arg
			end
			
			def show_faces=(arg)
				@@show_faces = arg
			end
			
			def show_wireframe
				@@show_wireframe
			end
			
			def show_faces
				@@show_faces
			end
		end
	end
end
