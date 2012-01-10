module Wireframe
	class Box < WireframeObj
		@@show_wireframe = true
		@@show_faces = true
		@@show_flattened = true
		@@show_only_selected = false
		
		@@all = Set.new # Hold all wireframes
		
		alias :old_draw :draw
		alias :old_init :initialize
		
		attr_accessor :selected
		
		def initialize(window, entity)
			old_init window, entity
			@@all.add self
			
			@selected = false
		end
		
		def draw(camera)
			if (@@show_only_selected && @selected) || !@@show_only_selected
				if @@show_wireframe
					draw_wireframe camera
				end
				
				if @@show_faces
					draw_faces camera
				end
			end
			
			if @@show_flattened
				draw_flat camera
			end
		end
		
		def draw_flat(camera)
			# Render the faces of the flattened version of the level
			# Code copied from Wireframe::Box.draw_sides and repurposed accordingly
			z = compute_z camera
			transparency = 0xcc
			zoom = camera.zoom
			height = 1
			
			
			quad_colors = [0xffee44, 0xff0011, 0x2244ff, 0x116622]
			4.times do |i|
				#~ quad_colors[i] = (transparencies[i] << 24) | quad_colors[i]
				quad_colors[i] = (transparency << 24) | quad_colors[i]
			end
			
			@color.alpha = transparency
			
			[2, 3, 1, 0].each do |i|
				vertex = @vertices[i]
				next_vertex = @vertices[i+1]
				next unless next_vertex
				
				#~ @window.draw_quad vertex[0], vertex[1], quad_colors[i],
								#~ next_vertex[0], next_vertex[1], quad_colors[i],
								#~ vertex[0], vertex[1] - 1, quad_colors[i],
								#~ next_vertex[0], next_vertex[1] - 1, quad_colors[i],
									#~ z, :default, zoom
				@window.draw_quad vertex[0], vertex[1], quad_colors[i],
								next_vertex[0], next_vertex[1], quad_colors[i],
								vertex[0], vertex[1] - height, quad_colors[i],
								next_vertex[0], next_vertex[1] - height, quad_colors[i],
								z, :default, zoom
			end
			
			
			# Quad for the top side of the box
			color = 0xffffff
			color = (transparency << 24) | color
			#~ z = @entity.pz+@entity.py_+@entity.height(:meters)
			
			@window.draw_quad	@vertices[0][0], @vertices[0][1]-height, color,
								@vertices[1][0], @vertices[1][1]-height, color,
								@vertices[2][0], @vertices[2][1]-height, color,
								@vertices[3][0], @vertices[3][1]-height, color,
								z, :default, zoom
		end
		
		def select
			@selected = !@selected
		end
		
		class << self
			def show_wireframe=(arg)
				@@show_wireframe = arg
			end
			
			def show_faces=(arg)
				@@show_faces = arg
			end
			
			def show_flattened=(arg)
				@@show_flattened = arg
			end
			
			def show_only_selected=(arg)
				@@show_only_selected = arg
			end
			
			def show_wireframe
				@@show_wireframe
			end
			
			def show_faces
				@@show_faces
			end
			
			def show_flattened
				@@show_flattened
			end
			
			def show_only_selected
				@@show_only_selected
			end
			
			def all
				# Return set of all wireframe objects
				@@all
			end
		end
	end
end
