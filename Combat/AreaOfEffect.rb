# Create rules for different effect areas (including splash)
# for various skills.
require 'set'

module AreaOfEffect
	class AoE_Object
		# This is the base for all classes which specify effect areas
		attr_reader :caster, :range
		
		# Due to the nature of the underlying chipmunk physics system,
		# the effect area must be initialized as this object is created.
		# Once created, #target will be used to rotate the area into position,
		# and the collision callback used to determine which objects to apply the
		# effect on to.  This is unfortunate, as the game speed will be limited by
		# the number of entities in the space, of which these will be members.
		
		def initialize(space, caster, range)
			@space = space
			@caster = caster
			@range = range
			
			@targets = Set.new
			
			# Use a trick from Java, and have this implement the collision handler interface
			self.class.set_collision_function @space, :area
			# Make sure to add the sensor object ::to the space
		end
		
		def update
			
		end
		
		def target(entity=nil)
			# Set the given entity to be the target of the effect
			# If no target is specified, then create one.
			# Use position and direction of caster as a basis, and
			# take into account the range of the spell.
			if entity
				return entity
			else
				px = 0
				py = 0
				pz = 0
				return Target.new(px, py, pz)
			end
		end
		
		def each(&block)
			# Return an iterator over all the objects which can be hit this frame.
			if block
				
			else
				@targets.each block
			end
		end
		
		
		class << self
			# Set this variable to true when the collision function has been added to the space.
			# Use metaclass instance var instead of class var so it is not inherited.
			@collision_function_active = false
			
			def set_collision_function(space, area_name)
				unless @collision_function_active
					space.add_collision_function area_name, :entity, self
					@collision_function_active = true
				end
			end
			
			# Place the callback functions in the class instead of the instance, so that
			# there is no confusion about scope.
			def begin(arbiter)
				# Touched for the first time this step
				# Return true to process normally, or false to ignore
				# Returning false skips the pre-solve and post-solve callbacks
				return true
			end
			
			def pre_solve(arbiter) 
				#Determine whether to process collision or not
				# The two shapes are touching.
				# Can override collision values like e and u here
				return true
			end
			
			def post_solve(arbiter) 
				#Do stuff after the collision has be evaluated
				# Two shapes are touching and collision response has been processed.
				# Can retrieve collision force now.
				return true
			end
			
			def separate(arbiter)
				#Stuff to do after the shapes separate
				# Shapes stopped touching for the first time this step
				return true
			end
		end
		
		private
		
		Target = Struct.new(:px, :py, :pz)
	end
	
	class Splash < AoE_Object
		# Hits the specified target, and then effects the surrounding area
		def initialize(space, caster, range, target=nil)
			super(space, caster, range, target)
			
		end
		
		def update
			
		end
		
		def each(&block)
			# Return an iterator over all objects hit this frame
			
		end
	end
	
	class AoE < AoE_Object
		# Targets a region around the caster.  Thus, this is actually a PBAoE
		def initialize(space, caster)
			super(space, caster, range, target)
			
		end
		
		def update
			
		end
		
		def each(&block)
			# Return an iterator over all objects hit this frame
			
		end
	end
	
	class Spin < AoE_Object
		# Similar to AoE, but rotate through targets instead of hitting
		# all in the area at once.
		# Similar to Link's spin attack, thus the name.
		def initialize(space, caster)
			# Create a rod in the space, and then rotate it around the caster
			# Remember to move the rod and rotation point as the caster moves
			# 
			# Caster should probably have reduced movement while using a spin move
			# 	or at the very least, it should be modified in some way
			# 
			# Knockback should be torque-based, like a baseball bat.
			super(space, caster, range, target)
			
		end
		
		def update
			
		end
		
		def each(&block)
			# Return an iterator over all objects hit this frame
			
		end
	end
	
	class Slash < AoE_Object
		# Similar to Spin, but with a smaller arc.
		# Spin attacks through the entire 360 deg arc, while Slash is more
		# like the 2D LoZ sword strike.
		# Angles are in radians, with 0 rad being directly in front of the caster.
		# Angle measure increases in the clockwise direction, in accordance with Chipmunk.
		def initialize(space, caster, start_angle, end_angle)
			super(space, caster, range, target)
			
		end
		
		def update
			
		end
		
		def each(&block)
			# Return an iterator over all objects hit this frame
			
		end
	end
	
	class Line < AoE_Object
		# Moves in a straight line towards the target from the caster.
		def initialize(space, caster, target, range=nil)
			super(space, caster, range, target)
			
		end
		
		def update
			
		end
		
		def each(&block)
			# Return an iterator over all objects hit this frame
			
		end
	end
	
	class Fan < AoE_Object
		# Fans out from the caster's position
		# Creates a pie-slice shaped AoE.  If this was 3D, it would be a cone.
		def initialize(space, caster, target)
			super(space, caster, range, target)
			
		end
		
		def update
			
		end
		
		def each(&block)
			# Return an iterator over all objects hit this frame
			
		end
	end
end
