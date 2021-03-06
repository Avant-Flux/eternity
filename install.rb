#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'

# Current installer will always attempt to install the bundler gem
# TODO: Install glut32.dll to C:\Windows\system
# 		Available here: http://user.xmission.com/~nate/glut.html
# 		ALTERNATIVELY: Use FreeGLUT instead, as it is more up to date.
# 		Will have to rename the dll from freeglut.dll to glut32.dll though.
# TODO: Only install bundler if not already installed
gems = %x[gem list]
unless gems.include? "bundler"
	if RUBY_PLATFORM.downcase.include?("mswin32")
		# Platform is Windows
		%x[gem install bundler]
	elsif RUBY_PLATFORM.downcase.include?("mingw")
		# Windows - RubyInstaller version
		%x[gem install bundler]
		
		puts "Bundler ready"

		puts "Dependencies will now install..."
		# Set up path to freeglut
		#~ freeglut_path = File.join Dir.pwd, "Dependencies", "freeglut"
		#~ %x[bundle config build.texplay --with-opt-dir="#{freeglut_path}"]
	elsif RUBY_PLATFORM.downcase.include?("darwin")
		# Install on OSX
		# NOTE: Assuming installation on MacRuby
		%x[sudo macgem install bundler]
	else
		# Assume all non-windows platforms are unix-based
		puts "NOT windows!"
		%x[sudo gem install bundler]
	end
end


exec "bundle install"
