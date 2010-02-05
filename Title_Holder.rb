#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 01.24.2010
 
class Title_Holder < Array
	def initialize(*args)
		super(*args)
	end
	
	def sort!(arg=:name)
		case arg
			when :name
				super() {|x,y| x.name <=> y.name}
			when :description
				super() {|x,y| x.description <=> y.description}
			when :effect
				super() {|x,y| x.effect <=> y.effect}
			when :points
				super() {|x,y| x.points <=> y.points}
		end
	end
	
	def sort(arg=:name)
		case arg
			when :name
				super() {|x,y| x.name <=> y.name}
			when :description
				super() {|x,y| x.description <=> y.description}
			when :effect
				super() {|x,y| x.effect <=> y.effect}
			when :points
				super() {|x,y| x.points <=> y.points}
		end
	end
	
	def push(*args)
		super(*args)
		sort!
	end
	
	def <<(*args)
		super(*args)
		sort!
	end
end