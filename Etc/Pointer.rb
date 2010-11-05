#!/usr/bin/ruby

class Pointer
	#Copy all the methods from @data
	
	
	def initialize(data)
		@data = data
	end
	
	def send(method, *args)
		@data.send method, args
	end
	
	#~ @data.methods.each do |method|
		#~ unless self.methods.include?(method)
			#~ define_method method do |*val|
				#~ puts method
				#~ @data.send method, val
			#~ end
		#~ end
	#~ end
end

x = Pointer.new(2)
puts "x+2: #{x.send :+, 2}"
