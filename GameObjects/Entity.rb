  1 #!/usr/bin/ruby
  2 
  3 require 'rubygems'
  4 require 'gosu'
  5 require 'chipmunk'
  6 
  7 require './Chipmunk/Space_3D'
  8 require './Chipmunk/EternityMod'
  9 require './GameObjects/Physics'
 10 require './Combat/Combative'
 11 require './Drawing/Animation'
 12 
 13 require './Stats/Stats'
 14 
 15 class Fixnum
 16 	def between?(a, b)
 17 		return true if self >= a && self < b
 18 	end
 19 end
 20 
 21 #Parent class of all Creatures, Fighting NPCs, and PCs
 22 class Entity
 23 	include Combative
 24 	include PhysicalProperties
 25 	
 26 	attr_reader :shape, :stats, :animations
 27 	attr_reader  :moving, :direction, :move_constant, :movement_force
 28 	attr_accessor :name, :elevation, :element, :faction, :visible
 29 	attr_accessor :lvl, :hp, :max_hp, :mp, :max_mp
 30 	
 31 	def initialize(space, animations, name, pos, mass, moment, lvl, element, stats, faction)
 32 		@movement_force = CP::Vec2.new(0,0)
 33 		@walk_constant = 500
 34 		@run_constant = 1200
 35 		
 36 		@animation = animations
 37 		
 38 		@shape = CP::Shape_3D::Circle.new(self, space, :entity, pos, 0,
 39 											(@animation.width/2).to_meters, 
 40 											@animation.height.to_meters,
 41 											mass, moment)
 42 		space.add self
 43 		
 44 		@name = name
 45 		@element = element
 46 		@faction = 0		#express faction spectrum as an integer, Dark = -100, Light = 100
 47 		@visible = true		#Controls whether or not to render the Entity
 48 
 49 		@lvl = lvl
 50 		@hp = {:current => 10, :max => 10}	#Arbitrary number for now
 51 		@mp = {:current => 10, :max => 10}
 52 		@stats = Hash.new
 53 		@stats[:raw] = stats
 54 		@stats[:composite] = {:atk => @stats[:raw][:str], :def => @stats[:raw][:con]}
 55 		
 56 		@jump_count = 0
 57 	end
 58 	
 59 	def update
 60 		@animation.direction = compute_direction
 61 		@animation.moving = moving?
 62 		@animation.update
 63 		
 64 		#~ if @shape.x.to_px - @animation.width <= 0
 65 			#~ @shape.x = @animation.width.to_meters
 66 		#~ end
 67 		#~ 
 68 		#~ if @shape.y.to_px - @animation.height <= 0
 69 			#~ @shape.y = @animation.height.to_meters
 70 		#~ end
 71 	end
 72 	
 73 	
 74 	def draw
 75 		if visible
 76 			@animation.draw @shape.x.to_px, @shape.y.to_px, @shape.z.to_px
 77 			#~ puts "#{@shape.x}, #{@shape.y}, #{@shape.z}"
 78 		end
 79 	end
 80 	
 81 	def step(dt)
 82 		if @shape.z == @shape.elevation
 83 			@jump_count = 0
 84 		end
 85 	end
 86 	
 87 	def jump
 88 		if @jump_count < 3 && @shape.vz <=0 #Do not exceed the jump count, and velocity in negative.
 89 			@jump_count += 1
 90 			@shape.vz = 5 #On jump, set the velocity in the z direction
 91 		end
 92 	end
 93 	
 94 	def move(dir)
 95 		angle =	case dir
 96 					when :up
 97 						((3*Math::PI)/2.0)
 98 					when :down
 99 						((Math::PI)/2.0)
100 					when :left
101 						(Math::PI)
102 					when :right
103 						0
104 					when :up_left
105 						((5*Math::PI)/4.0)
106 					when :up_right
107 						((7*Math::PI)/4.0)
108 					when :down_left
109 						((3*Math::PI)/4.0)
110 					when :down_right
111 						((Math::PI)/4.0)
112 				end
113 		
114 		unit_vector = angle.radians_to_vec2
115 		#~ scalar = (@shape.xy.body.v.dot(unit_vector))/(unit_vector.dot(unit_vector))
116 		#~ proj = (unit_vector * scalar)
117 		
118 		@movement_force = unit_vector * @move_constant
119 		
120 		@shape.body.apply_force @movement_force, CP::Vec2.new(0,0)
121 		@shape.body.a = angle
122 	end
123 	
124 	def walk
125 		@move_constant = @walk_constant
126 	end
127 	
128 	def run
129 		@move_constant = @run_constant
130 	end
131 	
132 	def moving?
133 		@shape.body.v.length >= 0
134 	end
135 
136 	def visible?
137 		@visible
138 	end
139 
140 	def set_random_element
141 		@element = case rand 5
142 			when 0
143 				:fire
144 			when 1
145 				:water
146 			when 2
147 				:earth
148 			when 3
149 				:wind
150 			when 4
151 				:lightning
152 		end
153 	end
154 	
155 	def create
156 		
157 	end
158 	
159 	def load
160 		
161 	end
162 	
163 	def save
164 		
165 	end
166 	
167 	def elevation
168 		@shape.elevation
169 	end
170 	
171 	def elevation=(arg)
172 		@shape.elevation = arg
173 	end
174 	
175 	def position
176 		"#{@name}: #{@shape.x}, #{@shape.y}, #{@shape.z}"
177 	end
183 	
184 	private	
185 	def compute_direction
186 		#~ puts @shape.a
187 		angle = @shape.body.a
188 		if angle.between?((15*Math::PI/8), (1*Math::PI/8))
189 			:right
190 		elsif angle.between?((1*Math::PI/8), (3*Math::PI/8))
191 			:down_right
192 		elsif angle.between?((3*Math::PI/8), (5*Math::PI/8))
193 			:down
194 		elsif angle.between?((5*Math::PI/8), (7*Math::PI/8))
195 			:down_left
196 		elsif angle.between?((7*Math::PI/8), (9*Math::PI/8))
197 			:left
198 		elsif angle.between?((9*Math::PI/8), (11*Math::PI/8))
199 			:up_left
200 		elsif angle.between?((11*Math::PI/8), (13*Math::PI/8))
201 			:up
202 		elsif angle.between?((13*Math::PI/8), (15*Math::PI/8))
203 			:up_right
204 		else
205 			:right #Workaround to catch the case where facing right is not being detected
206 		end
207 	end
208 end
