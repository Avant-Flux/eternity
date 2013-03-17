module Component
	class Model < Oni::Model
		MAX_NUMBER_OF_IDENTICAL_MESHES = 10000
		
		def initialize(window, mesh_name)
			# TODO: Create better Model ID assigning algorithm
			
			super window, "#{mesh_name}_#{id_number mesh_name}", "#{mesh_name}.mesh"
		end
		
		private
		
		def id_number(mesh_name)
			# Similar to cache mapping problem
			# random assignment is good enough in most cases
			# 
			# randomly assign id numbers
			# store assigned numbers in a set
			# re-roll on collision
			# remove ids as Mesh instances expire
			# 	should this be done in a finalizer?
			# 	should this move into the engine code so it can be explicitly triggered on GC?
			@@ids ||= Hash.new
			@@ids[mesh_name] ||= Set.new
			
			begin
				@id = rand MAX_NUMBER_OF_IDENTICAL_MESHES
				success = @@ids[mesh_name].add? @id
			end until success
		end
	end
end