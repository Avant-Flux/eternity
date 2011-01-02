#!/bin/bash

ruby_dev="ruby1.9.1-dev"
ruby_opengl="libopengl-ruby1.9.1"
gosu="g++ libgl1-mesa-dev libpango1.0-dev libboost-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev"
rmagick="libmagickcore-dev libmagickwand-dev"

install_command="sudo apt-get install"

dependency_installer="$install_command $ruby_dev $ruby_opengl $gosu $rmagick"

eval $dependency_installer

sudo gem install rake gosu chingu chipmunk rmagick texplay eventmachine require_all
