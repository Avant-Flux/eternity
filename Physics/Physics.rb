#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'
require "./Physics/PhysicsMixins"

class Numeric
	def to_px(zoom=1)
		# Convert from meters to pixels
		(self*Physics.scale*zoom).round
	end
	
	def to_meters
		# Convert from pixels to meters
		self/(Physics.scale.to_f) #Insure that integer division is not used
	end
	
	#Code taken from MoreChipmunkAndRMagick.rb from the gosu demos
	def radians_to_vec2
		CP::Vec2.new(Math::cos(self), Math::sin(self))
	end
	
	# Convert from degrees to radians
	def to_rad
		self * Math::PI / 180
	end
	
	# Convert from radians to degrees
	def to_deg
		self / Math::PI * 180
	end
end

module Physics
	MAX_Z = 10000000

	# Set the scale for conversion between meters and pixels
	@@scale = 640/165.0*100 # Pixels per meter
	class << self
		def scale
			@@scale
		end
		
		def scale=(arg)
			@@scale = arg
		end
	end
	
	module Direction
		X_HAT = CP::Vec2.new 1, 0
		Y_HAT = CP::Vec2.new(1, -1*Math.tan(70.to_rad)).normalize
		Z_HAT = CP::Vec2.new 0, -1
		
		N = Y_HAT
		S = -Y_HAT
		E = X_HAT
		W = -X_HAT
		NE = (N + E).normalize
		NW = (N + W).normalize
		SE = (S + E).normalize
		SW = (S + W).normalize
		
		N_ANGLE = N.to_angle
		S_ANGLE = S.to_angle
		E_ANGLE = E.to_angle
		W_ANGLE = W.to_angle
		NE_ANGLE = NE.to_angle
		NW_ANGLE = NW.to_angle
		SE_ANGLE = SE.to_angle
		SW_ANGLE = SW.to_angle
	end

	#This is the new structure for the chipmunk handling of the game engine
	#It should create a complete abstraction of the underlying chipmunk code.

	module TwoD_Support
		include Physics::Dimensions::TwoD
		include Physics::Chipmunk
		include Physics::Positioning
		include Physics::ForceApplication
		include Physics::Rotation
		include Physics::SpeedLimit
	
		def init_physics_base(position, mass, moment, collision_type)
			# Allow setting of static mass or moment
			if mass == :static
				mass = Float::INFINITY
			end
			if moment == :static
				moment = Float::INFINITY
			end
			
			body = Physics::Body.new self, mass, moment
			
			# Set up proper methods for accessing dimensions
			body.p.x = position[0]
			body.p.y = position[1]
			
			return body
		end
		
		module Circle
			def init_physics(position, radius, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::Circle.new self, body, radius, offset
				@shape.body.a = Physics::Direction::N_ANGLE
				@shape.collision_type = collision_type
			end
		end
		
		module Rect
			def init_physics(position, width, height, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::Rect.new self, body, width, height, offset
				@shape.collision_type = collision_type
			end
		end
		
		module Square
			def init_physics(position, side, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::Rect.new self, body, side, side, offset
				@shape.collision_type = collision_type
			end
		end
		
		module PerspRect
			def init_physics(position, width, height, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::PerspRect.new self, body, width, height, offset
				@shape.collision_type = collision_type
			end
		end
		
		module Poly
			def init_physics(position, verts, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				body = init_physics_base position, mass, moment, collision_type
				
				@shape = Physics::Shape::Poly.new self, body, verts, offset
				@shape.collision_type = collision_type
			end
		end
	end
	
	module ThreeD_Support
		# Include the methods from 2D, and change their names as necessary
		include TwoD_Support
		include Physics::Dimensions::ThreeD
		include Physics::Elevation
		
		def init_physics_base(position, mass, moment)
			# Allow setting of static mass or moment
			if mass == :static
				mass = Float::INFINITY
			end
			if moment == :static
				moment = Float::INFINITY
			end
			
			body = Physics::Body.new self, mass, moment
			
			body.p = Physics::Direction::X_HAT * position[0]
			body.p += Physics::Direction::Y_HAT * position[1]
			body.p += Physics::Direction::Z_HAT * position[2]
			
			return body
		end
		
		module StaticObject
			[:vz, :fz].each do |method|
				define_method method do
					return 0
				end
			end
			
			def init_static_layers
				sides
				@top_shape = top
				@render_object = render_object
			end
			
			def add_to(space)
				space.add @shape
				space.add @top_shape
				space.add @render_object
			end
			
			private
			
			def sides
				
			end
			
			def top
				# Displace by the height
				if @height.is_a? Proc
					# TODO: Fix this logic
					verts = []
					@shape.each_vertex do |v|
						verts << v
					end
					
					verts.length.times do |i|
						verts[i].y += @height.call verts[i].y, verts[i].y
					end
					
					return nil
				else
					shape = @shape.clone
					shape.body.p += Physics::Direction::Z_HAT * @height
					
					shape.collision_type = "#{@shape.collision_type}_top".to_sym
					
					return shape
				end
			end
			
			def render_object
				# Render object
				body = @shape.body
				
				vertices =	[[0, Physics::Shape::PerspRect::BOTTOM_LEFT_VERT], 
							[0, Physics::Shape::PerspRect::BOTTOM_RIGHT_VERT], 
							[0, Physics::Shape::PerspRect::TOP_RIGHT_VERT], 
							[1, Physics::Shape::PerspRect::TOP_RIGHT_VERT], 
							[1, Physics::Shape::PerspRect::TOP_LEFT_VERT], 
							[1, Physics::Shape::PerspRect::BOTTOM_LEFT_VERT]]
				
				vertices.each_with_index do |value, i|
					shape =	if value[0] == 0
								@shape
							elsif value[0] == 1
								@top_shape
							else
								raise ArgumentError, "Invalid shape selected"
							end
					vert_number = value[1]
					
					#~ puts shape.respond_to? :vert
					#~ puts shape.collision_type
					#~ puts shape.class
					
					#~ vert = shape.vert(vert_number)
					
					#~ shape.each_vertex do |v|
						#~ puts v
					#~ end
					
					vertex = shape.body.local2world(shape.vert(vert_number))
					vertices[i] = vertex
				end
				
				# Find center of the base, and use that as the offset
				offset = @shape.body.local2world(CP::Vec2::ZERO)
				
				vertices.each_with_index do |vert, i|
					vertices[i] -= offset
				end
				
				shape = Physics::Shape::Poly.new(self, body, vertices, CP::Vec2.new(0,-self.pz))
				
				shape.collision_type = "#{@shape.collision_type}_render_object".to_sym
				shape.sensor = true
				
				return shape
			end
		end
		
		module NonstaticObject
			# Create values needed to track the z coordinate
			attr_accessor :pz, :vz, :fz, :in_air, :elevation
			
			def init_nonstatic
				@pz = 0
				@vz = 0.to_f
				@fz = 0.to_f
				
				@in_air = false
				@elevation = 0
			end
		end
		
		module Box
			include StaticObject
			
			attr_reader :pz
			
			def init_physics(position, dimensions, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				# position		: x,y,z
				# dimensions	: width,depth,height
					# Height can either be Numeric or Proc
				
				# Generates a pseudo-3D box using the game's isometric projection
				# As this is only used for 3D objects, do not perform the CCW rotation
				# Create values needed to track the z coordinate
				@pz = position[2].to_f	#Force z to be a float just like x and y
				
				@height = dimensions[2]
				
				body = init_physics_base position, mass, moment
					
				# Create only the shape for the bottom.  The other shapes
				# will be created based off of that shape
				# There will also be one render object, and two collision objects
				# Thus, one collision obj for the "floor" and one for the "roof"
				
				@shape = Physics::Shape::PerspRect.new self, body, dimensions[0], dimensions[1], offset
				@shape.collision_type = collision_type
				
				init_static_layers
			end
		end
		
		module Prism
			include StaticObject
			
			def init_physics(position, verts, height, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				# Similar to Box, but with a Polygon for a base
				
			end
		end
		
		module Cylinder
			include NonstaticObject
			
			def init_physics(position, radius, mass, moment, collision_type, offset=CP::Vec2::ZERO)
				# Based on Circle
				body = init_physics_base position, mass, moment
				
				@shape = Physics::Shape::Circle.new self, body, radius, offset
				@shape.collision_type = collision_type
				
				init_nonstatic
			end
		end
	end
end
