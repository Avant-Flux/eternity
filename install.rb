#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'

begin
	require 'bundler/setup'
rescue LoadError
	if RUBY_PLATFORM.downcase.include?("mswin32")
		# Platform is Windows
		%x[gem install bundler]
	else
		# Assume all non-windows platforms are unix-based
		%x[sudo gem install bundler]
	end
	
	require 'bundler/setup'
end

puts "Bundler ready"
sleep(5)
