class StateManager
	def initialize(window, space, player)
		@window = window	# Parent window
		@space = space		# Chipmunk space used for queries and to add gameobjects to
		@player = player
		#~ @layers = layers	# Bitvector specifying which layers to use with Chipmunk
		
		@stack = Array.new()
		
		
		@npcs = Array.new
		@npcs[0] = Entity.new @window
		
		@entities = Array.new
		@entities.push @player
		@entities.push *@npcs
		
		
		@static_objects = Array.new
		@static_objects.push StaticObject.new @window, [50,50,0], [0,0,0] # Main area
		
		@static_objects.push StaticObject.new @window, [10,10,2], [-5,-5,0] # Raised spawn
		
		@static_objects.push StaticObject.new @window, [30,10,3], [20,50,0] # First step
		@static_objects.push StaticObject.new @window, [30,10,6], [20,60,0] # Second step
		
		@static_objects.push StaticObject.new @window, [15,15,1], [0,16,6] # Floating platform
		@static_objects.push StaticObject.new @window, [15,15,3], [15,16,0] # Step to floating platform
		
		@static_objects.each do |static|
			static.add_to @space
		end
		
		@entities.each do |entity|
			entity.add_to @space
		end
	end
	
	def update
		@entities.each do |entity|
			entity.update
		end
	end
	
	def draw
		draw_static_objects
		draw_shadows
		draw_ground_effects
		draw_entities
	end
	
	def draw_magic_circle(x,y,z)
		@magic_circle ||= Gosu::Image.new(@window, "./Sprites/Effects/firecircle.png", false)
		@magic_circle_angle ||= 0
		if @magic_circle_angle > 360
			@magic_circle_angle = 0
		else
			@magic_circle_angle += 1
		end
		zoom = 0.01
		color = Gosu::Color::RED
		
		@window.scale zoom,zoom, x,y do
			@magic_circle.draw_rot(x,y,z, @magic_circle_angle, 0.5,0.5, 1,1, color)
		end
	end
	
	private
	
	def draw_static_objects
		@static_objects.each do |static|
			@window.camera.draw_trimetric static.pz+static.height do
				static.draw_trimetric
			end
		end
	end
	
	def draw_entities
		@window.camera.draw_billboarded do
			@entities.each do |entity|
				entity.draw
			end
		end
	end
	
	def draw_shadows
		@entities.each do |entity|
			@window.camera.draw_trimetric entity.body.elevation do
				distance = entity.body.pz - entity.body.elevation
				a = 1 # Quadratic
				b = 1 # Linear
				c = 1 # Constant
				factor = (a*distance + b)*distance + c
				
				c = 1
				r = (entity.body.pz - entity.body.elevation + c)
				
				c = 1
				alpha = 1/factor
				@window.draw_circle	entity.body.p.x, entity.body.p.y, entity.body.elevation,
									r,	Gosu::Color::BLACK,
									:stroke_width => r, :slices => 20, :alpha => alpha
			end
		end
	end
	
	def draw_ground_effects
		@window.camera.draw_trimetric do
			draw_magic_circle	@player.body.p.x,@player.body.p.y,0
		end
	end
end
