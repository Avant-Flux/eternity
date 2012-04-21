#!/usr/bin/ruby
#Parent class of all Creatures, Fighting NPCs, and PCs
class Entity
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
	
	attr_accessor :pz
	attr_accessor :body, :shape
	
	#~ def initialize(window, animations, name, pos, mass, moment, lvl, element, faction=0)
	def initialize(window)
		@window = window
		
		@visible = true
		
		#~ File.join(Cacheable.sprite_directory, "People", "NewSprites.png")
		spritesheet_filename = "./Sprites/People/NewSprites.png"
		@spritesheet = Gosu::Image::load_tiles(window, spritesheet_filename, 295, 640, false)
		@sprite = @spritesheet[0]
		
		@body = CP::Body.new 60, CP::INFINITY
		@shape = CP::Shape::Circle.new @body, (@sprite.width/2).to_meters, CP::ZERO_VEC_2
		
		# Create values for 3rd dimension of physics
		@elevation = 0
		@pz = 0
		@vz = 0 
		@az = 0
		@g = -9.8
		
		
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
		
		#~ init_stats
		
		#~ @shadow = Shadow.new window, self
		#~ 
		#~ @intense = false
		#~ @visible = true		#Controls whether or not to render the Entity
		
		@jump_count = 0
	end
	
	def update
		i = if @body.f.y > 0
			0
		else
			1
		end
		@sprite = @spritesheet[i]
		
		dt = 1/60.0
		@vz += @az * dt
		@pz += @vz * dt
		if @pz < @elevation
			@pz = @elevation
			@vz = 0
			@az = 0
			resolve_ground_collision
		elsif @pz > @elevation
			# TODO: Change conditional to be if in_air? to handle uneven terrain
			# Apply gravity
			@vz += @g * dt
			@pz += @vz * dt
		else
			# Currently on the ground
		end
	end
	
	def draw(color)
		# Use z position in meters for z-index
		
		position = @body.p.to_screen
		x = position.x
		y = position.y - @pz.to_px
		
		# TODO may have to pass the z index from the game state manager
		if @visible
			@window.translate -@sprite.width/2, -@sprite.height do # Draw centered at base
				@sprite.old_draw x,y, @pz
				#~ @window.draw_quad	x, y, color,
									#~ x+width, y, color,
									#~ x+width, y+height, color,
									#~ x, y+height, color, @pz
			end
		end
	end
	
	def self.stats *arr
		# Method taken from _why's Dwemthy's Array
		# and subsequently modified
		return @default_stats if arr.empty?
		
		#~ attr_accessor *arr
		
		# Create one method to set each value, for the names given
		# in the arguments array
		arr.each do |method|
			meta_eval do
				define_method method do |val|
					@default_stats ||= {}
					@default_stats[method] = val # TODO: Use struct instead
				end
			end
		end
	end
	
	def init_stats
		@attributes = Hash.new
		@status = Hash.new
		
		@stats = Hash.new # TODO: Use struct instead of hash
		@stats[:raw] = {} # strength, constitution, dexterity, mobility, power, skill, flux
		
		self.class.stats.each do |stat, val|
			#~ instance_variable_set("@#{stat}", val)
			@stats[:raw][stat] = val
		end
		
		@stats[:composite]	=	{:attack => @stats[:raw][:strength], 
								:defence => @stats[:raw][:constitution]}
		
		@hp = {}
		@mp = {}
		
		@hp[:max] = @stats[:raw][:constitution]*17
		@hp[:current] = @hp[:max]
		
		@mp[:max] = 300# Arbitrary
		@mp[:current] = @mp[:max]
	end
	
	stats :strength, :constitution, :dexterity, :power, :control, :flux
	
	# Create setters and getters for hp and mp
	[:hp, :mp].each do |stat|
		define_method stat do ||
			instance_variable_get("@#{stat}".to_sym)[:current]
		end
		
		define_method "#{stat}=".to_sym do |val|
			instance_variable_get("@#{stat}".to_sym)[:current] = val
		end
		
		define_method "max_#{stat}".to_sym do ||
			instance_variable_get("@#{stat}".to_sym)[:max]
		end
	end
	
	def resolve_ground_collision
		@jump_count = 0
	end
	
	def jump
		if @jump_count < 3 #Do not exceed the jump count.
			@jump_count += 1
			@vz = 5 #On jump, set the velocity in the z direction
		end
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
		angle = self.a
		
		if angle.between? Physics::Direction::NE_ANGLE, Physics::Direction::SE_ANGLE
			return :right
		elsif angle.between? Physics::Direction::SE_ANGLE, Physics::Direction::SW_ANGLE
			return :down
		elsif angle.between? Physics::Direction::SW_ANGLE, Physics::Direction::NW_ANGLE
			return :left
		elsif angle.between? Physics::Direction::NW_ANGLE, Physics::Direction::NE_ANGLE
			return :up
		else
			:left
		end
	end
end
