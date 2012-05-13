#!/bin/bash

ruby_dev="ruby1.9.1-dev"
ruby_opengl="libopengl-ruby1.9.1"
gosu="build-essential freeglut3-dev libfreeimage-dev libgl1-mesa-dev libopenal-dev libpango1.0-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev libsndfile-dev libxinerama-dev"
#~ texplay="libglut3-dev" # or use freeglut3-dev, probably a better choice on Ubuntu
rmagick="libmagickcore-dev libmagickwand-dev"

install_command="sudo apt-get install"

dependency_installer="$install_command $ruby_dev $ruby_opengl $gosu $texplay"

eval $dependency_installer &&

sudo gem install rake gosu chipmunk texplay eventmachine require_all rmagick
