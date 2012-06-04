#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'

# Current installer will always attempt to install the bundler gem
# TODO: Only install bundler if not already installed
if RUBY_PLATFORM.downcase.include?("mswin32")
	# Platform is Windows
	puts "Windows!"
	%x[gem install bundler]
elsif RUBY_PLATFORM.downcase.include?("mingw")
	# Not sure what this windows is, but it's what you get
	# when you use the rubyinstaller.org version
	puts "Still windows!"
	%x[gem install bundler]
else
	# Assume all non-windows platforms are unix-based
	puts "NOT windows!"
	%x[sudo gem install bundler]
end

puts "Bundler ready"

puts "Dependencies will now install..."
exec bundle install
