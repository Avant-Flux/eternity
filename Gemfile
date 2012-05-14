source "http://gemcutter.org"

BASEPATH = File.absolute_path(File.dirname(__FILE__))

if RUBY_PLATFORM.downcase.include?("linux")
	# Check for existence of Gemfile.lock to determine if installer has been run before
	unless File.exists?(File.join BASEPATH, "Gemfile.lock")
		puts "Installing for linux"
		
		# Installer expects a Debian-based OS
		
		# Install all system dependencies for gems
		dependencies = {
			"ruby dev" => "ruby1.9.1-dev",
			"ruby opengl" => "libopengl-ruby1.9.1",
			"gosu" => "build-essential freeglut3-dev libfreeimage-dev libgl1-mesa-dev libopenal-dev libpango1.0-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev libsndfile-dev libxinerama-dev"
			#~ "texplay" => "libglut3-dev" # or use freeglut3-dev, probably a better choice on Ubuntu
			#~ "rmagick (imagemagick)" => "libmagickcore-dev libmagickwand-dev"
		}
		
		install_command = "sudo apt-get install"
		
		# Run installer over command line
		dependencies.each do |name, packages|
			unless system("#{install_command} #{packages}")
				puts "Dependencies for #{name} have failed to install."
				puts "Installer will quit."
				puts "Installation has FAILED."
				
				exit
			end
		end
	end
elsif RUBY_PLATFORM.downcase.include?("mswin32")
	puts "Installing for windows"
	
	gem "ruby-opengl", :require => ["gl", "glu"]
elsif RUBY_PLATFORM.downcase.include?("darwin")
	puts "Installing for OSX"
	
	gem "ruby-opengl", :require => ["gl", "glu"]
	#~ sudo gem install rake #rake is installed by default
	#Gems do not appear to need separate dependencies on OSX
	#with the exception of imagemagick
	
	#Install imagemagick dependencies
	#~ sudo port install tiff -macosx imagemagick +q8 +gs +wmf
	
	#~ sudo gem1.9 install ruby-opengl gosu chingu chipmunk texplay eventmachine require_all
	
	
	
	#~ sudo gem install gosu chipmunk texplay eventmachine require_all
end

gem "rake"
gem "gosu", "~>0.7.43"
gem "chipmunk", "~>5.3.4.5"
gem "texplay", "~>0.4.2"
#~ gem "rmagick", "~>2.13.1", :require => "RMagick"
gem "eventmachine", "~>0.12.10"
gem "require_all"