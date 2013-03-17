module Component
	class Model < Oni::Model
		def initialize(window, mesh_name)
			super window, "#{mesh_name}_#{object_id}", "#{mesh_name}.mesh"
		end
	end
end