#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 01.18.2010
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
			`gksudo gem install ruby-opengl`
		end
	end
	
	def gosu
		if @os == "linux"
			`gksudo apt-get install g++ libgl1-mesa-dev libpango1.0-dev libboost-dev libsdl-mixer1.2-dev`
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
	
	def devil
		`sudo apt-get install libdevil1c2 libdevil-dev`
		`sudo gem install devil texplay`
	end
end


Installer.new.run
