#!/usr/bin/ruby

require 'rubygems'
require 'gosu'
require 'chingu'
#~ require 'chipmunk'
#~ require 'require_all'
#~ require_all './Chipmunk'
#~ require_all './Combat'
#~ require_all './Drawing'

require './Chipmunk/Shape'
require './Chipmunk/Space'
require './Chipmunk/Shape_3D'
require './Chipmunk/Space_3D'
require './Chipmunk/EternityMod'

require './Combat/Combative'

require './Drawing/Animation'
require './Drawing/Background'
require './Drawing/GosuPatch'
require './Drawing/Ground'
require './Drawing/GUI'
require './Drawing/Shadow'
require './Drawing/Wireframe'

require './Equipment/Equipment'

require './GameObjects/Building'
require './GameObjects/Entity'
require './GameObjects/Creature'
require './GameObjects/Character'
require './GameObjects/Player'
require './GameObjects/NPC'
require './GameObjects/Physics'
require './GameObjects/Camera'

require './Stats/Element'
require './Stats/StatGrowth'
require './Stats/StatRates'
require './Stats/Stats'

require './Titles/Title'
require './Titles/Title_Holder'

require './UI/StatusOverlay'
require './UI/TrackingOverlay'

require './Utilities/ArtManager'
require './Utilities/FPSCounter'
require './Utilities/InputHandler'



require 'test/unit'

class UnitTests < Test::Unit::TestCase
	def test_combat
		
	end
	
	def test_
		
	end
end
