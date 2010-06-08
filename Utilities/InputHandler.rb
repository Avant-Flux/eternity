# File created by
#	Chad Godsey
#	Feb 21, 2010
#Modified by Jason Ko
#	Date last edited: 06.08.2010
#
#	InputHandler class
#		used to manage button mappings to several types of high level input
#			simple named actions
#			chords - multiple buttons at once
#			sequences - combos
#
begin
  # In case you use Gosu via RubyGems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end
require 'gosu'

class InputHandler
	
	def initialize()
		@chords = { }
		@sequences = {}
		@actions = {}
		
		@sequence_hist = []
		
		@time = Gosu::milliseconds
	end
	
	def button_down(id)
		# Update chords
		@chords.select{ |k,c| 
			c[:buttons].include?(id) 
		}.each{ |k,c| 
			i = c[:buttons].index(id)
			c[:active][i] = true 
			if c[:state] == :idle
				c[:time] = @time
				c[:state] = :process
			end
			unless c[:active].include?(false)
				c[:state] = :begin
			end
		}
		# Update sequences with start state
		for seq in @sequence_hist
			if id == seq[:seq][:buttons][seq[:index]] and seq[:index] == (seq[:seq][:buttons].size-1)
				seq[:seq][:state] = :begin
			end
		end
		
		# Update actions
		@actions.select{ |k,a| 
			a[:buttons].include?(id) 
		}.each{ |k,a| 
			a[:state] = :begin
		}
	end
	
	def button_up(id)
		# Invalidate current sequences
		# Update current sequences
		for seq in @sequence_hist
			if id != seq[:seq][:buttons][seq[:index]] 
				unless seq[:seq][:state] == :active
					seq[:valid] =false
					seq[:seq][:state] = :idle
				end
			else
				seq[:lasttime] = @time
				seq[:index] += 1
				if seq[:index] == seq[:seq][:buttons].size
					seq[:seq][:state] = :finish
				end
			end
		end
		@sequence_hist.delete_if { |s| not s[:valid] }
		
		# Start new sequences
		for seq in @sequences.values
			if id == seq[:buttons][0]
				seq[:state] = :process
				ns = {}
				ns[:seq] = seq
				ns[:lasttime] = @time
				ns[:index] = 1
				ns[:valid] = true
				@sequence_hist << ns
			end
		end
		
		# Invalidate chords
		@chords.select{ |k,c| 
			c[:buttons].include?(id) 
		}.each{ |k,c| 
			if c[:state] == :active
				c[:state] = :finish 
			else
				c[:state] = :idle 
			end
			c[:time] = -1
			c[:active].fill(false) 
		}
		
		# Update actions
		@actions.select{ |k,a| 
			a[:buttons].include?(id) 
		}.each{ |k,a| 
			a[:state] = :finish
		}
	end
	
	def active?(action)
		query(action) == :active
	end
	
	def update
		@time += Gosu::milliseconds
		
		# Update chords from end state to idle
		# Invalidate old chords
		@chords.each{ |k,c| 
			if c[:state] == :begin
				c[:state] = :active
			elsif c[:state] == :finish
				c[:state] = :idle
			elsif c[:state] == :process and c[:time] < @time - 100 
														#Time in milliseconds between chord "notes"
				c[:state] = :idle
				c[:active].fill(false)
			end
		}
		
		# Invalidate old sequences
		@sequence_hist.select { |s| 
			s[:lasttime] < (@time - s[:seq][:threshold]) and s[:seq][:state] != :active 
		}.each{ |s|
			s[:seq][:state] = :idle
		}
		@sequence_hist.delete_if { |s| s[:lasttime] < (@time - s[:seq][:threshold]) and s[:seq][:state] != :active }
		# Update sequence states
		@sequences.select{ |k,c| 
			c[:state] == :begin
		}.each{ |k,c| 
			c[:state] = :active
		}
		@sequences.select{ |k,c| 
			c[:state] == :finish
		}.each{ |k,c| 
			c[:state] = :idle
		}
		
		# Update actions
		@actions.each{ |k,a| 
			if a[:state] == :begin
				a[:state] = :active
			elsif a[:state] == :finish
				a[:state] = :idle
			end
		}
	end
	
	## Main interface for state queries
	## should be pretty obvious how to use
	def query(name)
		if @sequences[name]
			return @sequences[name][:state]
		elsif @chords[name]
			return @chords[name][:state]
		elsif @actions[name]
			return @actions[name][:state]
		else
			return :invalid
		end
	end
	
	##
	## Begin Construction methods
	## (this interface could be a lot better, but meh)
	
	def createAction(name)
		@actions[name] = {
			:state => :idle,
			:buttons => []
		}
	end
	
	def bindAction(name, button)
		@actions[name][:buttons] << button
	end
	
	def clearAction(name)
		@actions[name][:buttons].clear
	end
	
	def clearActions()
		@actions.clear
	end
	
	def createChord(name)
		@chords[name] = {
			:state => :idle,
			:buttons => [],
			:active => [],
			:time => -1
		}
	end
	
	def bindChord(name, button)
		@chords[name][:buttons] << button
		@chords[name][:active] << false
	end
	
	def clearChord(name)
		@chords[name][:buttons].clear
		@chords[name][:active].clear
	end
	
	def clearChords()
		@chords.clear
	end
	
	def createSequence(name, threshold)
		@sequences[name] = {
			:state => :idle,
			:buttons => [],
			:threshold => threshold
		}
	end
	
	def pushSequence(name, button)
		@sequences[name][:buttons] << button
	end
	
	def clearSequence(name)
		@sequences[name][:buttons].clear
	end
	
	def clearSequences()
		@sequences.clear
	end

end
