#!/usr/bin/ruby
# Taken from _why's Seeing Metaclasses Clearly
# src: http://viewsourcecode.org/why/hacking/seeingMetaclassesClearly.html

class Object
	def self.metaclass
		class << self
			self
		end
	end
	
	def meta_eval(&block)
		metaclass.instance_eval &block
	end
	
	# Add methods to metaclass
	def meta_def name, &block
		meta_eval do
			define_method name, &block
		end
	end
	
	# Defines an instance method within a class
	def class_def name, &block
		class_eval do
			define_method name, &block
		end
	end
end
