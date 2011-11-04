# Example interface for the story system

class Merchants < Faction
	nation	:Fire
	
	# watch for other_faction to perform an action, and then deal with that information
	watch other_faction do |event|
		event.name
		event.type
		event.agent_of_change
		
		#~ respond_to event.type
	end
	
	# Specify a group of factions to observe
	watch_all factions_in_group do |event|
		
	end
	
	# If any events like these occur, then react
	watch_world do |event|
		
	end
	
	# if attacked, in general
	anticipate_attack do |event|
		
	end
	
	# if attacked by a particular faction
	anticipate_attack_from other_faction do |event|
		
	end
end
