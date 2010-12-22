#!/usr/bin/ruby

require 'rubygems'
require 'require_all'
require 'gosu'
require 'chingu'
require 'chipmunk'


#~ require_all './Combat'
#~ require_all './Drawing'

require_all './Chipmunk'

require './Combat/Combative'

require_all './Drawing/'

require './Equipment/Equipment'

require_all './GameObjects'

require './Stats/Element'
require './Stats/StatGrowth'
require './Stats/StatRates'
require './Stats/Stats'

require './Titles/Title'
require './Titles/Title_Holder'

require_all './UI'

require_all './Utilities'



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
	def setup
		@window = Gosu::Window.new(640, 480, false)
	end

	def test_image_clone
		width, height = 10, 30
		color = [1.0, 1.0, 0.0, 1.0]
		img = TexPlay.create_image(@window, width, height, :color => color)
		
		assert img.methods.include?(:clone), "Gosu::Image#clone is not defined."
		
		img2 = img.clone
		assert_equal(img.to_blob, img2.to_blob, "Binary representation of clones is different.")
		assert_equal(img, img2, "Gosu::Image#== not defined.  Using default implementation.")
	end

	def test_subsprite
		
	end

	def test_sprite
		sub1 = Subsprite.new('./')
		sub2 = Subsprite.new('./')
		sprite = Sprite.new(width, height, sub1, sub2)
		
		assert_instance_of Array, sprite[:down]
		assert_instance_of Gosu::Image, sprite[:down][0]
	end

	def test_art_manager
		#Make sure the art manager starts
		@art_manager = ArtManager.new './Sprites'
		assert_instance_of ArtManager,  @art_manager

		#Art manager assumes that all assets are of the PNG filetype.
		asset_1 = @art_manager.new_animation	:body => 1, :face => 1, :hair => 1, 
												:upper => "shirt1", :lower => "pants1", 
												:footwear => "shoes1"
		asset_2 = @art_manager.new_texture "grass"
		asset_3 = @art_manager.new_effect "Dark_Cloud"
		
		
		
		#The same asset loaded twice is just a shallow copy the second time
		asset_4 = @art_manager.new_animation	:body => 1, :face => 1, :hair => 1, 
												:upper => "shirt1", :lower => "pants1", 
												:footwear => "shoes1"
		assert_equal asset_1, asset_4
		#Same data, but not same reference
		assert !same_asset1.equal?(same_asset2)
	end

	def test_combat
		
	end
end
