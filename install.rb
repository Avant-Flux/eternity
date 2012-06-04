#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'

puts RUBY_PLATFORM.downcase
sleep(30)

begin
	require 'bundler/setup'
rescue LoadError
	if RUBY_PLATFORM.downcase.include?("mswin32")
		# Platform is Windows
		puts "Windows!"
		sleep(30)
		%x[gem install bundler]
	else
		# Assume all non-windows platforms are unix-based
		puts "NOT windows!"
		sleep(30)
		%x[sudo gem install bundler]
	end
	
	require 'bundler/setup'
end

puts "Bundler ready"
sleep(5)
