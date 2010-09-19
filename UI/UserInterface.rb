#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 09.18.2010

#~ This package serves as a meta-package which allows all of the UI files to be loaded.

require 'rubygems'
require 'gosu'
require 'chingu'

require 'chipmunk'
require 'Chipmunk/Space_3D'

require 'GameObjects/Entity'
require "GameObjects/Creature"
require 'GameObjects/Character'
require 'GameObjects/Player'

require 'UI/TrackingOverlay.rb'
require 'UI/StatusOverlay.rb'
