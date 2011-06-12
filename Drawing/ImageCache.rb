#!/usr/bin/ruby

module Cacheable
	# Assumes that the class which includes this module implements 
	# the methods Class#hash and Class.hash
	# Class.hash should essentially be a procedural variant of Class#hash
	# 	The class method should return the hash code if an object of that class was to be created
	# 	with the given parameters.
	# All methods in this module (with the exception of #new) should be implemented procedurally
	# Use the symbol corresponding to the class and not the class itself
	
	def new(*args)
		# reimplement #new to make caching transparent
		init_cache
		
		if cache_include?(*args)
			return read_cache(*args)
		else
			cache super(*args)
		end
	end
	
	def init_cache
		# The scope of this class variable is this module
		# It does not get mixed-in
		
		# Nested hash
		# Outer hash is the class of the object to be stored
		# Inner hash in the specific object
		@@cache ||= Hash.new
		#~ @@cache[self.class.name.to_sym] ||= Hash.new
		#~ self.subcache ||= Hash.new
		init_subcache
	end
	
	def cache(obj)
		# Store the current object in the cache
		Cacheable.subcache(obj.class)[obj.hash] = self
	end
	
	def read_cache(*args)
		# Load an object with the given hashcode
		self.subcache[self.hash]
	end
	
	def cache_include?(*args)
		# Returns true if there is an object with the given hash code in the cache
		self.subcache.include? self.class.hash(*args)
	end
	
	def cache_delete
		# remove this object from cache
		self.subcache.delete self
	end
	
	def subcache
		# Return the hash corresponding to the cache for this class type only
		Cacheable.subcache self.class
		#~ @@cache[self.class.name.to_sym]
	end
	
	def subcache=(arg)
		@@cache[self.class.name.to_sym] = arg
	end
	
	class << self
		def subcache(klass)
			# Return the subcache corresponding to the given class
			@@cache[klass.name.to_sym]
		end

		def clear_cache(klass)
			# Clear the cache for the given class
			#~ @@cache[self.class.name.to_sym].clear
			Cacheable.subcache(klass).clear
		end
	end
	
	private
	def init_subcache
		@@cache[self.class.name.to_sym] ||= Hash.new
	end
end

