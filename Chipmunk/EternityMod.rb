#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 07.25.2010
require 'rubygems'
require 'chipmunk'
require 'Chipmunk/Shape_3D'

module CollisionHandler
	#a corresponds to the shape of the first type passed to add_collision_handler
	#b corresponds to the second

	#Control collisions between multiple Entity objects
	class Entity
		#~ attr_reader :begin_called, :pre_called, :post_called, :sep_called
		
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
		#~ attr_reader :begin_called, :pre_called, :post_called, :sep_called
		
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
		def sep(a,b,arbiter)	#Stuff to do after the shapes separate
			
		end
	end
end

#This file should contain all Eternity-specific Chipmunk-related code 

#~ class Entity_Body < Body_3D
	#~ def initialize(space, x, y, z, width, height, mass=100, moment=150)
		#~ super(space, x, y, z, width, height, :entity_bottom, :entity_side, mass, moment)
		#~ 
		#~ xy_collision_fx do |b1_shape, b2_shape|
			#~ if 
				#~ nil
			#~ else
				#~ nil
			#~ end
			#~ 1
		#~ end
		#~ 
		#~ xz_collision_fx do |s1_shape, s2_shape|
			#~ nil
		#~ end
	#~ end
#~ end
#~ 
#~ class Building_Body < Body_3D
	#~ def initialize(space, x, y, z, width, height)
		#~ super(space, x, y, z, width, height, :building_bottom, :building_side, 
				#~ Float::INFINITY, Float::INFINITY)
		#~ 
		#~ xy_collision_fx do |b1_shape, b2_shape|
			#~ 1
		#~ end
		#~ 
		#~ xz_collision_fx do |s1_shape, s2_shape|
			#~ nil
		#~ end
	#~ end
#~ end
