#!/bin/bash

#~ sudo gem install rake #rake is installed by default
#Gems do not appear to need separate dependencies on OSX
#with the exception of imagemagick

#Install imagemagick dependencies
#~ sudo port install tiff -macosx imagemagick +q8 +gs +wmf
sudo gem1.9 install ruby-opengl gosu chingu chipmunk texplay eventmachine require_all

