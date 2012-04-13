class StateManager
	def initialize(window, space, layers)
		@window = window	# Parent window
		@space = space		# Chipmunk space used for queries and to add gameobjects to
		@layers = layers	# Bitvector specifying which layers to use with Chipmunk
		
		@stack = Array.new()
	end
	
	def update
		@stack.each_with_index do |state, i|
			if state.gc
				# GC if flagged
			elsif state.update?
				state.update
			end
		end
	end
	
	def draw
		@stack.each_with_index do |state, i|
			if state.visible?
				state.draw 
				@window.flush
			end
		end
	end
	
	def load(klass, *args)
		
	end
	
	def dump(name)
		# Save all states in the state manager to the disk
		#~ File.open("path/to/output.yml", "w") {|f| f.write(data.to_yaml) }
	end
	
	def pop
		# Pop the top state off the stack and save it
		@stack.pop.save
	end
	
	def save(name)
		# Save state with the given name
		@stack.each do |state|
			if state.name == name
				state.save
			end
		end
	end
	
	def save_at(i)
		# Save the state at the given index
		@stack[i].save
	end
	
	def save_all
		# Save all states
		@stack.each do |state|
			
		end
	end
	
	def clear
		# Save states and clear the stack
		save_all
		@stack.clear
	end
end
