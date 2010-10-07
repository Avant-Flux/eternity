#~ sudo gem install rake #rake is installed by default
#Gems do not appear to need separate dependencies on OSX
#with the exception of imagemagick
sudo port install tiff -macosx imagemagick +q8 +gs +wmf
sudo gem install ruby-opengl gosu chingu chipmunk rmagick texplay eventmachine
