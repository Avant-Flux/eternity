module Component
	class Model
		def initialize(window, mesh_name)
			# TODO: Create better Model ID assigning algorithm
			
			@model = Oni::Agent.new window,	"#{mesh_name}_#{id_number mesh_name}", 
											"#{mesh_name}.mesh"
		end
		
		def update(dt)
			@model.update dt # TODO: Move to animation component
		end
		
		def visible?
			@model.visible?
		end
		
		def visible=(visibility)
			@model.visible = visibility
		end
		
		private
		
		def id_number(mesh_name)
			# @@resources = {
				# "name" => [count, stack]
			# }
			
			
			@@resources ||= Hash.new # Store counts for each mesh, so each new mesh is given a new ID
			
			@@resources[mesh_name] ||= [0]
			
			count = @@resources[mesh_name].pop
			@@resources[mesh_name] << count + 1
			
			
			
			
			
			
			
			if @@resources[mesh_name].size == 1
				# Use the only number in the stack
				count = @@resources[mesh_name].top
			else
				# Recycle old numbers before making new ones
				
			end
			
			@@resources[mesh_name] += 1
		end
	end
end