module Component
	class Model
		def initialize(window, mesh_name)
			# TODO: Create better Model ID assigning algorithm
			@@resources ||= Hash.new # Store counts for each mesh, so each new mesh is given a new ID
			
			@@resources[mesh_name] ||= 0
			@@resources[mesh_name] += 1
			@model = Oni::Agent.new window,	"#{mesh_name}_#{@@resources[mesh_name]}", 
											"#{mesh_name}.mesh"
		end
		
		def visible?
			
		end
		
		def visible=(visibility)
			
		end
	end
end