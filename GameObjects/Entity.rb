#!/usr/bin/ruby
#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
	include PhysicsInterface
	include Statistics
	#~ include Physics::ThreeD_Support
	#~ include Physics::ThreeD_Support::Cylinder
	#~ include Physics::Movement::Entity
	
	#~ include Combative
	
	#~ attr_reader :name, :stats, :lvl, :element
	#~ attr_reader  :moving, :move_constant, :movement_force
	#~ attr_accessor :faction, :visible, :intense
	#~ # Attributes:	Innate properties
	#~ # Status:		Properties imposed by effects, like status effects
	#~ attr_reader :attributes, :status
	
	attr_accessor :body, :shape
	attr_reader :level
	
	strength		1
	constitution	1
	dexterity		1
	power			1
	control			1
	flux			1
	
	#~ def initialize(window, animations, name, pos, mass, moment, lvl, element, faction=0)
	def initialize(window)
		@window = window
		
		@visible = true
		
		#~ File.join(Cacheable.sprite_directory, "People", "NewSprites.png")
		#~ spritesheet_filename = "./Sprites/People/NewSprites.png"
		spritesheet_filename = "./Sprites/People/male_spritesheet.png"
		@spritesheet = Gosu::Image::load_tiles(window, spritesheet_filename, -4, -2, false)
		@sprite = @spritesheet[0]
		
		# TODO: Allow setting mass and moment through constructor, or based on stats
		init_physics	:entity, Physics::Shape::Circle.new(self, 
						Physics::Body.new(self, 60, CP::INFINITY), 
						(@sprite.width/2).to_meters)
		
		#~ @name = name
		#~ @lvl = lvl
		#~ @element = element
		#~ @faction = faction		#express faction spectrum as an integer, Dark = -100, Light = 100
		#~ 
		#~ @animation = animations
		#~ 
		#~ # Radius was originally set to @animation.width/2.0, changed to better match
		#~ # human sprite width at maximum resolution
		#~ init_physics	pos, (@animation.width/3.5).to_meters, mass, moment, :entity
		#~ init_movement	
		
		init_stats
		@level = 1
		
		#~ @intense = false
		#~ @visible = true		#Controls whether or not to render the Entity
	end
	
	def update
		@sprite = @spritesheet[compute_direction]
	end
	
	def draw_trimetric
		
	end
	
	def draw_billboarded
		# Use z position in meters for z-index
		
		position = @body.p.to_screen
		x = position.x
		y = position.y - @body.pz.to_px
		
		# TODO may have to pass the z index from the game state manager
		#~ if @visible && @window.camera.visible?(self)
			@window.translate -@sprite.width/2, -@sprite.height do # Draw centered at base
				@sprite.draw x,y, z_index
				#~ @window.draw_quad	x, y, color,
									#~ x+width, y, color,
									#~ x+width, y+height, color,
									#~ x, y+height, color, @pz
			end
		#~ end
	end
	
	def draw_shadow
		distance = @body.pz - @body.elevation
		a = 1 # Quadratic
		b = 1 # Linear
		c = 1 # Constant
		factor = (a*distance + b)*distance + c
		
		c = 1
		r = (@body.pz - @body.elevation + c)
		
		c = 1
		alpha = 1/factor
		@window.draw_circle	@body.p.x, @body.p.y, @body.elevation,
							r,	Gosu::Color::WHITE,
							:stroke_width => r, :slices => 20, :alpha => alpha
	end
	
	def z_index
		return @body.pz
	end
	
	def resolve_ground_collision
		reset_jump
	end
	
	def visible?
		@visible
	end
	
	def create
		
	end
	
	def load
		
	end
	
	def save
		
	end
	
	def position
		"#{@name}: #{px}, #{py}, #{pz}, elevation: #{elevation}"
	end
	
	private
	
	def compute_direction
		#~ angle = @body.a
		#~ puts angle
		
		# All angles are in CP space - thus, radians
		#~ puts angle + Math::PI # 2PI is left, angle increases CCW
		#~ puts ((angle + Math::PI)/(Math::PI*2))*8
		
		#~ return (((@body.a + Math::PI)/(Math::PI*2))*8).to_i - 1
		return 4*@body.a/Math::PI + 3
	end
end
