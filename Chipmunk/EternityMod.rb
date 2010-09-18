#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.18.2010
require 'rubygems'
require 'chipmunk'
require 'Chipmunk/Shape_3D'

module CollisionHandler
	#a corresponds to the shape of the first type passed to add_collision_handler
	#b corresponds to the second

	#Control collisions between multiple Entity objects
	class Entity
		#~ def begin(a,b,arbiter)
			#~ @begin_called = [a,b]
		#~ end
		#~ 
		#~ def pre(a,b,arbiter) #Determine whether to process collision or not
		#~ end
		#~ 
		#~ def post(a,b,arbiter) #Do stuff after the collision has be evaluated
		#~ end
		#~ 
		#~ def sep(a,b,arbiter)	#Stuff to do after the shapes separate
			#~ 
		#~ end
	end
	
	#Control collisions between an Entity and the environment
	#	ie, a character and a building or land mass
	class Entity_Env #Specify entity first, then the environment piece
		def begin(a,b,arbiter)
			#~ @begin_called = [a,b]
			return true
		end
		
		def pre_solve(a,b,arbiter) #Determine whether to process collision or not
			#Process actions involving what to do when on top, as well as side collisions
			if a.z < b.height #If the entity collides from the side, accept the collision
				return true
			else
				a.elevation = b.height
				return false
			end
		end
		
		def post_solve(a,b,arbiter) #Do stuff after the collision has be evaluated
			#~ puts "you"
		end
		
		def separate(a,b,arbiter)	#Stuff to do after the shapes separate
			a.elevation = 0
		end
	end
	
	#~ Collision type for usage with the CP::Shape and CP::Body used for the camera
	class Camera
		def initialize(camera) #Argument should be the actual camera
			
		end
	
		def begin(a,b,arbiter)
			
		end
		
		def pre(a,b,arbiter) #Determine whether to process collision or not
			
		end
		
		def post(a,b,arbiter) #Do stuff after the collision has be evaluated
			#~ This will never be called for a sensor object.
		end
		
		def sep(a,b,arbiter)	#Stuff to do after the shapes separate
			
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
		self/(CP::Space_3D.scale * 1.0) #Insure that integer division is not used
	end
end
