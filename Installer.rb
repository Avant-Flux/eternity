#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.19.2010

#Note: Program crashes after installing opengl
#Files install, but there is no command line notification of anything happening

#To install ruby on ubuntu, install ruby1.9.1-full and rubygems1.9.1
require 'rbconfig' 

class Installer
	@os
	
	def initialize
		@os = RbConfig::CONFIG['target_os']
	end
	
	def run
		ruby_dev
		rake
		gosu
		chingu
		chipmunk
		opengl
		devil_and_texplay
		imagemagick
	end
	
	def rake
		if @os == "linux"
			`gksudo gem install rake`
		end
	end
	
	def ruby_dev
		if @os == "linux"
			`gksudo apt-get install ruby1.9.1-dev`
		end
	end
	
	def opengl
		if @os == "linux"
			`gksudo apt-get install libgl1-mesa-dri libglu1-mesa freeglut3 libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev`
			#Use this command now on Ubuntu as this gem is packaged separately
			#	Actually, that is false.  This package is just needed FIRST
			`gksudo apt-get install libopengl-ruby1.9`
			`gksudo gem install ruby-opengl`
		end
	end
	
	def gosu
		if @os == "linux"
			`gksudo apt-get install g++ libgl1-mesa-dev libpango1.0-dev libboost-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev`
			`gksudo gem install gosu`
		end
	end
	
	def chingu
		if @os == "linux"
			`gksudo gem install chingu`
		end
	end
	
	def chipmunk
		if @os == "linux"
			`gksudo gem install chipmunk`
		end
	end
	
	def devil_and_texplay
		#~ `gksudo apt-get install libdevil1c2 libdevil-dev`
		`gksudo gem install texplay`
	end
	
	def imagemagick
		`gksudo apt-get install libmagickcore-dev libmagickwand-dev`
		`gksudo gem install rmagick`
		
		if @os == "Windows"
			`gem install rmagick-win32`
		end
	end
	
	def eventmachine
		if @os == "linux"
			`gksudo gem install eventmachine`
		end
	end
end


Installer.new.run
