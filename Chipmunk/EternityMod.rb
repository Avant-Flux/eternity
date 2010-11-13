#!/usr/bin/ruby

require 'rubygems'
require 'chipmunk'
require './Chipmunk/Shape_3D'

module CollisionHandler
	#a corresponds to the shape of the first type passed to add_collision_handler
	#b corresponds to the second

	#Control collisions between multiple Entity objects
	class Entity
		def begin(a,b,arbiter)
			return true
		end
		
		def pre_solve(a, b, arbiter) #Determine whether to process collision or not
			#Process actions involving what to do when on top, as well as side collisions
			
			#First, determine which one is higher
			if a.z > b.z #a is higher
				higher = a
				lower = b
			elsif a.z < b.z #b is higher
				higher = b
				lower = a
			else #They are at the same z position (z is a double, this will almost never happen)
				return true	#When two things are at the same z position, there should be a collision
			end
			
			#See if the higher one is high enough to pass over the lower one
			if higher.z < lower.height
				#The higher of the two is not high enough to clear the other one
				return true
			else
				#The higher one was high enough.  Ignore the collision so the higher can pass 
				#"though" (read: over) the lower one.
				return false
			end
		end
		
		def post_solve(a,b,arbiter) #Do stuff after the collision has be evaluated
			
		end
		
		def separate(a,b,arbiter)	#Stuff to do after the shapes separate
			
		end
	end
	
	#Control collisions between an Entity and the environment
	#	ie, a character and a building or land mass
	class Entity_Env #Specify entity first, then the environment piece
		def begin(a,b,arbiter)
			return true
		end
		
		def pre_solve(a,b,arbiter) #Determine whether to process collision or not
			#Process actions involving what to do when on top, as well as side collisions
			if a.z < b.height #If the entity collides from the side, accept the collision
				return true
			else
				#~ a.elevation = b.height
				
				all_ones = 2**32-1
				a.space.point_query CP::Vec2.new(a.x,a.y), all_ones,0 do |env|
					#~ puts env.class
					if env.is_a?(CP::Shape_3D::Rect) || env.is_a?(CP::Shape_3D::Circle)
						#~ p env
						if env.height > a.elevation
							a.elevation = env.height
						end
					end
				end
				
				return false
			end
		end
		
		def post_solve(a,b,arbiter) #Do stuff after the collision has be evaluated
			
		end
		
		def separate(a,b,arbiter)	#Stuff to do after the shapes separate
			a.elevation = 0
		end
	end
end

module CP
	class Space_3D
		@@scale = 44
		
		class << self
			def scale
				@@scale
			end
			
			def scale= arg
				@@scale = arg
			end
		end
	end
end

class Numeric
	def to_px
		#~ Convert from meters to pixels
		self*CP::Space_3D.scale
	end
	
	def to_meters
		#~ Convert from pixels to meters
		self/(CP::Space_3D.scale.to_f) #Insure that integer division is not used
	end
end
