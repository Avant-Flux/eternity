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
require './DebugCode'
#~ assert(boolean)
#~ assert_equal(expected, actual)
#~ assert_not_equal(expected, actual)
#~ assert_raise(exception_type, ...) { block }
#~ assert_nothing_raised(exception_type, ..) { }
#~ assert_instance_of(class_expected, object)
#~ flunk

class UnitTests < Test::Unit::TestCase
	def test_subsprite
		
	end

	def test_sprite
		
	end

	def test_art_manager
		#Make sure the art manager starts
		@art_manager = ArtManager.new './Sprites'
		assert_instance_of ArtManager,  @art_manager
		
		#The same asset loaded twice is just a shallow copy the second time
		same_asset1 = @art_manager.new_asset(:animation, :fire_character)
		same_asset2 = @art_manager.new_asset(:animation, :fire_character)
		assert_equal same_asset1, same_asset2
		#Same data, but not same reference
		assert not same_asset1.equal(same_asset2)
		#Still, 
		
		
		@art_manager.new_asset(:animation, :fire_character, 
								)
	end

	def test_combat
		
	end
end
