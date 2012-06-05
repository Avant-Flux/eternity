# Similar to StaticObject, but contains a warp to a new level
# Thus, this object must manage the loading and saving of this 
# new zone.  
# 	Load the new zone when within the camera's load distance
# 	Save and free when outside a certain distance
# Should draw billboarded component, and provide method for drawing 
# trimetric component as well
class Building
	def initialize
		# Physics init
		# Door init
		# Establish level to load
		# 	Perhaps use metaprogramming interface for clean decedent implementation
	end
	
	# Load the contents of the building
	def load
		
	end
	
	# Save the contents of the building to the disk
	def save
		
	end
end
