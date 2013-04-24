module Item # must be in module so that constants can be searched
	class Equipment
		attr_reader :model
		
		def initialize(window, name)
			@model = Component::Model.new window, name
		end
		
		# Apply effect
		def equip
			
		end
		
		# Remove effect
		def unequip
			
		end
	end

	class Armor < Equipment
		attr_reader :animation
		
		def initialize(window, name, physics)
			super(window, name)
			
			@physics = physics
			
			@animation = Oni::Animation.new @model
			
			
			# It complains that the skeletons are different...?
			# @animation.share_skeleton_with @base_animation, 1.0
		end
		
		def update(dt)
			@model.update dt
			
			# Copied from Component::Collider::Base in Compnents/Physics.rb
			# TODO: Depreciate this section when the skeleton is shared.  Failing that, make sure the entire Entity uses the same transforms so that this becomes unnecessary
			@model.position = [@physics.body.p.x, @physics.body.pz, -@physics.body.p.y]
			@model.rotation = @physics.body.a + Math::PI/2
		end
		
		def equip
			
			
			super
		end
		
		def unequip
			
			
			super
		end
		
		# Sync with the base animation
		# This should probably be depreciated in favor of setting the correct values for all parts only as necessary
		def sync_animation(other_animation)
			@animation.animations.each do |animation_name|
				if other_animation[animation_name].enabled?
					@animation[animation_name].enable
					
					# Copy state from base
					@animation[animation_name].weight = other_animation[animation_name].weight
					@animation[animation_name].time = other_animation[animation_name].time
					@animation[animation_name].loop = other_animation[animation_name].loop
					@animation[animation_name].rate = other_animation[animation_name].rate
				else
					@animation[animation_name].disable
				end
			end
		end
	end

	class Head < Armor
		def initialize(window, name, physics)
			super(window, name, physics)
		end
	end

	class Body < Armor
		def initialize(window, name, physics)
			super(window, name, physics)
		end
	end

	class Legs < Armor
		def initialize(window, name, physics)
			super(window, name, physics)
		end
	end

	class Feet < Armor
		def initialize(window, name, physics)
			super(window, name, physics)
		end
	end

	class Hands < Armor
		def initialize(window, name, physics)
			super(window, name, physics)
		end
	end

	class Weapon < Equipment
		RIGHT_HAND_BONE_NAME = "hand.R"
		LEFT_HAND_BONE_NAME = "hand.L"
		
		def initialize(window, name, base_model, position, rotation)
			super(window, name)
			
			@base_model = base_model
			
			@position = position
			@rotation = rotation
		end
		
		def update(dt)
			
		end
		
		private :equip
		def equip_to(hand)
			case hand
				when :right
					@base_model.attach_object_to_bone RIGHT_HAND_BONE_NAME, @model
				when :left
					@base_model.attach_object_to_bone LEFT_HAND_BONE_NAME, @model
				else
					raise "Weapon must be placed in either the left or right hand."
			end
			
			# @model.position = [0,0,0]
			# @model.rotation_3D = [0,0,0,0]
			@model.position = @position
			# @model.rotation_3D = @rotation
			
			equip()
		end
		
		def unequip
			@base_model.detach_object_from_bone @model
			
			super
		end
	end
end